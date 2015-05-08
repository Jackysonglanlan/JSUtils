//
//  JSMessageBusTests.m
//  JSUtils
//
//  Created by Song Lanlan on 1/5/15.
//  Copyright (c) 2015 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"

#import "JSMessageBus.h"

@interface JSMessageBusTests : AbstractTests

@end

@implementation JSMessageBusTests{
    JSMessageBus *bus;
}

- (void)before {
    bus = [JSMessageBus defaultMessageBus];
}

- (void)mockMsg {
    static int count = 0;

    if (count > 3) return;
    
    [bus publish:@(count++)];

    [self performSelector:@selector(mockMsg) withObject:nil afterDelay:1];
}

- (void)after {
    
}

- (void)testFunction{
    [self addSub1];
    [self addSub2];
    [self addSub3];
    
    [bus setDidFinishProcessingMessage:^(id msg) {
        DLog(@"finish --- %@", msg);
    }];

    [bus setDidFinishProcessingAllMessages:^{
        DLog(@"finish all ---");
        [Executors dispatchAsyncToMainThread:^{
            [self finishedAsyncOperation];
        }];
    }];
    
    [self mockMsg];

    [self beginAsyncOperationWithTimeout:1000];
}

- (void)addSub1 {
    JSMessageBusSubscriber *sub = [JSMessageBusSubscriber new];
    sub.priority = 1;
    [sub setMessageFilter:^BOOL(id msg) {
        return YES;
    }];
    [sub setMessageHandler:^(id msg, JSMBOperator *op) {
        DLog(@"111 %@",msg);
//        [op forward:msg toSubscriberWithPriority:3];
        [op pass:msg];
    }];
    [bus registerSubscriber:sub];
}

- (void)addSub2 {
    JSMessageBusSubscriber *sub2 = [JSMessageBusSubscriber new];
    sub2.priority = 2;
    [sub2 setWillStartProcessingMessage:^(id msg) {
        DLog(@"sub2 will process %@", msg);
    }];
    [sub2 setMessageFilter:^BOOL(id msg) {
        return NO;
    }];
    [sub2 setMessageHandler:^(id msg, JSMBOperator *op) {
        // code should not run here
        DLog(@"222 %@",msg);
        [op finishBus:msg];
    }];
    [bus registerSubscriber:sub2];
}

- (void)addSub3 {
    JSMessageBusSubscriber *sub3 = [JSMessageBusSubscriber new];
    sub3.priority = 3; 
    [sub3 setMessageFilter:^BOOL(id msg) {
        return YES;
    }];
    [sub3 setMessageHandler:^(id msg, JSMBOperator *op) {
        DLog(@"333 %@",msg);
        [Executors dispatchAsyncToMainThread:^{
            [op performSelector:@selector(pass:) withObject:msg afterDelay:2];
        }];
//        [sub3 finishHandleMessage:msg];
    }];
    [bus registerSubscriber:sub3];
}

@end
