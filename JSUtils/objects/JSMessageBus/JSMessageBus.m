//
//  JSMessageBus.m
//  JSUtils
//
//  Created by Song Lanlan on 1/5/15.
//  Copyright (c) 2015 Jacky.Song. All rights reserved.
//

#import "JSMessageBus.h"

#import "JSShortHand.h"

@implementation JSMessageBus{
    NSMutableDictionary *subscriberTable; // @{JSMessageBusSubscriber.priority -> JSMessageBusSubscriber}
    NSMutableArray *priorityArray;// @[JSMessageBusSubscriber.priority]
    
    BOOL isPublishing;
    NSMutableArray *messageQueue; //
    dispatch_queue_t worker;
    
    JSMBOperator *busOperator;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        subscriberTable = [[NSMutableDictionary alloc] initWithCapacity:5];
        priorityArray = [[NSMutableArray alloc] initWithCapacity:5];
        messageQueue = [NSMutableArray new];
        
        worker = dispatch_queue_create("JSMessageBus_worker", DISPATCH_QUEUE_SERIAL);
        
        busOperator = [JSMBOperator new];
        [busOperator setBus:self]; // duck typing
    }
    return self;
}

- (void)dealloc{
    JS_releaseSafely(subscriberTable);
    JS_releaseSafely(priorityArray);
    JS_releaseSafely(messageQueue);
    dispatch_release(worker);
    
    JS_releaseSafely(_didFinishProcessingMessage);
    JS_releaseSafely(_didFinishProcessingAllMessages);
    
    JS_releaseSafely(busOperator);
    [super dealloc];
}

#pragma mark private

- (void)enqueueMessage:(id)msg {
    DLog(@"Add new message into queue: [%@]", msg);
    [messageQueue insertObject:msg atIndex:0];
}

- (id)dequeueMessage {
	id msg = [messageQueue lastObject];
	[messageQueue removeLastObject];
	return msg;
}

- (void)doInOneThread:(dispatch_block_t)task {
    dispatch_async(worker, task);
}

- (JSMessageBusSubscriber*)findSubscriberByIndexOfPriorityArray:(NSUInteger)index {
    return subscriberTable[priorityArray[index]];
}

- (void)sortPriorityArrayLowToHigh:(NSInteger)priority {
    [priorityArray addObject:@(priority)];
    [priorityArray sortUsingSelector:@selector(compare:)];
}

- (void)checkDuplicateSubscriber:(JSMessageBusSubscriber*)subscriber {
    JSMessageBusSubscriber *existSub = subscriberTable[@(subscriber.priority)];
    if (!existSub) return;
    
    JS_Stub_Throw(@"Duplicate subscriber", @"Already has subscriber %@ of the same priority [%ld]",
                  existSub.class, (long)subscriber.priority);
}

#pragma mark message handling

- (void)doLoadMessageIntoBus:(id)msg {
    if (priorityArray.count == 0) {
        DLog(@"No JSMessageBusSubscriber, quit...");
        return;
    }
    
    [self enqueueMessage:msg];
    
    [self doWhenStartMsgBus];
}

- (void)finishMessageProcessingWithMessage:(id)msg {
    NSInteger last = priorityArray.count - 1;
    [self passMessageToNextSubscriber:msg fromSubscriber:[self findSubscriberByIndexOfPriorityArray:last]];
}

- (void)forwardMessage:(id)message toSubscriberWithPriority:(NSInteger)priority{
    NSInteger index = [priorityArray indexOfObject:@(priority)];
    
    if (index < 0 || index > priorityArray.count - 1) {
        JS_Stub_Throw(@"Invalid priority value", @"Message bus has no subscriber with priority [%ld]", (long)priority);
    }
    
    NSInteger targetIndex = index - 1;
    
    [self passMessageToNextSubscriber:message fromSubscriber:[self findSubscriberByIndexOfPriorityArray:targetIndex]];
}

// fromSub = nil means fromSub is the first one in priorityArray
- (void)passMessageToNextSubscriber:(id)msg fromSubscriber:(JSMessageBusSubscriber*)fromSub{
    [self doInOneThread:^{
        [self doPassMessageToNextSubscriber:msg fromSubscriber:fromSub];
    }];
}
- (void)doPassMessageToNextSubscriber:(id)msg fromSubscriber:(JSMessageBusSubscriber*)fromSub{
    BOOL isReachTheEnd = (fromSub.priority == [[priorityArray lastObject] integerValue]);
    if (isReachTheEnd) {
        [self doWhenFinishProcessingMessage:msg];
        
        id nextMsg = [self dequeueMessage];
        if (nextMsg) {
            DLog(@"There are still messages in queue, continue publishing message [%@]", nextMsg);
            return [self doPassMessageToNextSubscriber:nextMsg fromSubscriber:nil];
        }
        
        [self doWhenAllMessagesAreProcessed];
        
        return;
    }
    
    NSUInteger fromSubIndex = (fromSub == nil) ? -1 : [priorityArray indexOfObject:@(fromSub.priority)];
    JSMessageBusSubscriber *nextSub = [self findSubscriberByIndexOfPriorityArray:fromSubIndex + 1];
    
    [self linkOperatorToSubscriber:nextSub];
    
    if (nextSub.willStartProcessingMessage) {        
        nextSub.willStartProcessingMessage(msg);
    }
    
    if (nextSub.messageFilter(msg)){
        DLog(@"Ready to pass message [%@] to %@", msg, nextSub);
        nextSub.messageHandler(msg, busOperator);
        return;
    }
    
    DLog(@"%@ doesn't accept msg [%@], try next one...", nextSub, msg);
    
    // recursion pass til we find one that accept this msg
    [self doPassMessageToNextSubscriber:msg fromSubscriber:nextSub];
}

- (void)linkOperatorToSubscriber:(JSMessageBusSubscriber*)subscriber {
    // duck typing
    [busOperator setSubscriber:subscriber];
}

- (void)doWhenStartMsgBus{
    if (isPublishing) return;
    isPublishing = YES;

    DLog(@"Start message bus now...");
    
    [self passMessageToNextSubscriber:[self dequeueMessage] fromSubscriber:nil];
}

-(void)doWhenFinishProcessingMessage:(id)msg{
    DLog(@"Message Bus finish processing message [%@]", msg);
    
    if(self.didFinishProcessingMessage){
        self.didFinishProcessingMessage(msg);
    }
}

- (void)doWhenAllMessagesAreProcessed {
    DLog(@"All messagese are processed, stop bus now...");
    
    if(self.didFinishProcessingAllMessages){
        self.didFinishProcessingAllMessages();
    }
    
    isPublishing = NO;
}

#pragma mark public

static NSMutableDictionary *busSingletonTable;
+(void)initialize{
    if (self != JSMessageBus.class) return;
    
    busSingletonTable = [[NSMutableDictionary alloc] initWithCapacity:3];
}

+ (instancetype)defaultMessageBus {
    return [self messageBusOfReuseIdentifier:@"__JSMessageBus.default.bus__"];
}

+ (instancetype)messageBusOfReuseIdentifier:(NSString*)reuseId {
    JSMessageBus *bus = busSingletonTable[reuseId];
    
    if (!bus){
        bus = [[JSMessageBus new] autorelease];
        busSingletonTable[reuseId] = bus;
    }
    
    return bus;
}

- (void)publish:(id)msg {
    [self doInOneThread:^{
        [self doLoadMessageIntoBus:msg];
    }];
}

-(void)registerSubscriber:(JSMessageBusSubscriber*)subscriber{
    [self checkDuplicateSubscriber:subscriber];
    
    subscriberTable[@(subscriber.priority)] = subscriber;
    [self sortPriorityArrayLowToHigh:subscriber.priority];// sync subscriberTable and priorityArray
}

@end
