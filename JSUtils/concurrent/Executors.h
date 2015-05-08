//
//  Executors.h
//
//  Created by jacky.song on 12-8-17.
//  Copyright (c) 2012 Symbio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Executors : NSObject

+(void)dispatchAsync:(dispatch_queue_priority_t)priority task:(dispatch_block_t)task;

+(void)dispatchSync:(dispatch_queue_priority_t)priority task:(dispatch_block_t)task;

+(void)dispatchAsyncToMainThread:(dispatch_block_t)task;

+(void)dispatchSyncToMainThread:(dispatch_block_t)task;

+(void)concurrentProcessTasks:(NSUInteger)count stride:(NSUInteger)stride task:(void (^)(NSUInteger index))task;

@end
