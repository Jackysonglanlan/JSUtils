//
//  NSObject+GCDSLL.m
//  JSUtils
//
//  Created by jackysong on 14-9-16.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "NSObject+GCDSLL.h"

@implementation NSObject(GCDSLL)

+ (void)jsPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delayInSec{
    [self jsPerformBlock:block afterDelay:delayInSec inQueue:dispatch_get_main_queue()];
}

+ (void)jsPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delayInSec inQueue:(dispatch_queue_t)queue{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSec * NSEC_PER_SEC));
    
	dispatch_after(popTime, queue, block);
}

@end
