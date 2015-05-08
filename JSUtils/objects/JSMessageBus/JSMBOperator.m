//
//  JSMBOperator.m
//  JSUtils
//
//  Created by Song Lanlan on 8/5/15.
//  Copyright (c) 2015 Song Lanlan. All rights reserved.
//

#import "JSMBOperator.h"

#import "JSMessageBus.h"
#import "JSMessageBusSubscriber.h"

@interface JSMBOperator()
@property(nonatomic,assign) JSMessageBus *bus;
@property(nonatomic,assign) JSMessageBusSubscriber *subscriber;
@end

@implementation JSMBOperator

- (void)pass:(id)message {
    DLog(@"%@ finish handle message [%@], pass to next...", self.subscriber, message);
    
    // duck typing
    [self.bus passMessageToNextSubscriber:message fromSubscriber:self.subscriber];
}

- (void)forward:(id)message toSubscriberWithPriority:(NSInteger)priority{
    DLog(@"%@ finish handle message [%@], forward to subscriber with priority[%ld]...",
         self.subscriber, message, (long)priority);
    
    // duck typing
    [self.bus forwardMessage:message toSubscriberWithPriority:priority];
}

- (void)finishBus:(id)message {
    DLog(@"%@ finish message bus processing with message [%@], no feather processing...", self.subscriber, message);
    
    // duck typing
    [self.bus finishMessageProcessingWithMessage:message];
}

@end
