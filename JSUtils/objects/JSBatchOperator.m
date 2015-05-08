//
//  JSBatchOperator.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-3-4.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "JSBatchOperator.h"
#import "JSMacros.h"

@implementation JSBatchOperator{
    NSMutableArray *queue;
    dispatch_queue_t worker;
}

- (id)init{
    self = [super init];
    if (self) {
        worker = dispatch_queue_create("__JSBatchOperator__worker", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)setValve:(NSUInteger)valve{
    _valve = valve;
    JS_STUB_STANDARD_SETTER(queue, [[[NSMutableArray alloc] initWithCapacity:valve] autorelease]);
}

- (void)dealloc{
    JS_releaseSafely(_doAsyncBatchOp);
    JS_releaseSafely(_didFinishProcessing);
    JS_releaseSafely(queue);
    dispatch_release(worker);
    [super dealloc];
}

#pragma mark private

-(void)doInOneThread:(dispatch_block_t)task{
    dispatch_sync(worker, task);
}

-(void)triggerBatchOp:(NSUInteger)maxBatchSize force:(BOOL)force{
    if (!force && queue.count < self.valve) {
        return;
    }
    
    [self doInOneThread:^{
        if (queue.count == 0){
            if(self.didFinishProcessing) {
                self.didFinishProcessing();
            }
            return;
        }

        NSRange itemsToBatch = NSMakeRange(0, maxBatchSize);
        NSArray *tmp = [queue subarrayWithRange:itemsToBatch];
        if (self.doAsyncBatchOp) {
            self.doAsyncBatchOp(tmp);// call block
        }
        
        [queue removeObjectsInRange:itemsToBatch];// clean
        
        // recursive process, do it in another queue, or it'll dead-lock.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self triggerBatchOp:self.valve force:force];
        });
    }];
}

#pragma mark public

-(NSUInteger)remainItemsCount{
    return queue.count;
}

-(void)addItem:(id)item{
    NSAssert(self.valve != 0, @"Must set *valve* before use");
    
    [self doInOneThread:^{
        [queue addObject:item];
    }];
    
    // trigger block
    [self triggerBatchOp:self.valve force:NO];
}

-(void)forceBatchOpWithAllItems{
    [self triggerBatchOp:queue.count force:YES];
}

@end
