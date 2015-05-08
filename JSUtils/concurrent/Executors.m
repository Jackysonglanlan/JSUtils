//
//  Executors.m
//
//  Created by jacky.song on 12-8-17.
//  Copyright (c) 2012 Symbio. All rights reserved.
//

#import "Executors.h"

@implementation Executors

+(void)dispatchAsync:(dispatch_queue_priority_t)priority task:(dispatch_block_t)task{
    dispatch_async(dispatch_get_global_queue(priority, 0), task);
}

+(void)dispatchSync:(dispatch_queue_priority_t)priority task:(dispatch_block_t)task{
    dispatch_sync(dispatch_get_global_queue(priority, 0), task);
}

+(void)dispatchAsyncToMainThread:(dispatch_block_t)task{
    dispatch_async(dispatch_get_main_queue(), task);
}

+(void)dispatchSyncToMainThread:(dispatch_block_t)task{
    dispatch_sync(dispatch_get_main_queue(), task);
}

+(void)concurrentProcessTasks:(NSUInteger)count stride:(NSUInteger)stride task:(void (^)(NSUInteger index))task{
    // concurrent process
    dispatch_apply(count/stride, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^(size_t idx) {
                       NSUInteger start = idx * stride;
                       NSUInteger stop = start + stride;
                       
                       do {
                           task(start++);
                       } while (start < stop);
                       
//                       NSLog(@"%u, %u",start,stop);
                   });
    // the rest, linear process
    NSUInteger i;
    for (i = count - (count % stride); i < count; i++){
        task(i);
    }
}

@end
