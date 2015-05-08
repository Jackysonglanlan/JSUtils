//
//  JSBatchOperator.h
//  CMGESocialSDK
//
//  Created by jackysong on 14-3-4.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSBatchOperator : NSObject

// the valve to trigger the batchOp block to be called.
@property(nonatomic, assign) NSUInteger valve;

// called when the item count exceed the valve.
@property(nonatomic, copy) void (^doAsyncBatchOp)(NSArray *items);

// called when all the items are being processed.
@property(nonatomic, copy) void (^didFinishProcessing)(void);

-(NSUInteger)remainItemsCount;
-(void)addItem:(id)item;
-(void)forceBatchOpWithAllItems;

@end
