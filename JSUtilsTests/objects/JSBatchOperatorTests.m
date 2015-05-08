//
//  UtilsObjectsTests.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-3-4.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "JSBatchOperator.h"

#import "AbstractTests.h"

@interface JSBatchOperatorTests : AbstractTests

@end

@implementation JSBatchOperatorTests

-(void)before{
}

-(void)after{
}

-(void)testBatchOperator{
    JSBatchOperator *bo = [JSBatchOperator new];
    bo.valve = 5;
    
    [bo setDoAsyncBatchOp:^(NSArray *items) {
        [items log];
    }];
    
    [bo setDidFinishProcessing:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self finishedAsyncOperation];
        });
    }];
    
    for (int i=1; i<=13; i++) {
//        [NSThread sleepForTimeInterval:1];
        [bo addItem:@(i)];
//        NSLog(@"add %d",i);
    }
    
    [bo forceBatchOpWithAllItems];
    
    [self beginAsyncOperation];
    [self waitForAsyncOperationOrTimeoutWithDefaultInterval];
}

@end
