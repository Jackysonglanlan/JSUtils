//
//  NSObject+GCDSLL.h
//  JSUtils
//
//  Created by jackysong on 14-9-16.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(GCDSLL)

+ (void)jsPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delayInSec;
+ (void)jsPerformBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delayInSec inQueue:(dispatch_queue_t)queue;

@end
