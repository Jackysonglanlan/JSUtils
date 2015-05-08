//
//  CountDownLatch.h
//  template_ios_project
//
//  Created by Lanlan Song on 12-4-6.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountDownLatch : NSObject{
  @private
  NSUInteger counter;
  dispatch_semaphore_t semaphore;
}

// Constructs a CountDownLatch initialized with the given count.
- (id)initWithCount:(NSUInteger)count;

/*
 * Decrements the count of the latch, releasing all waiting threads if
 * the count reaches zero.
 */
- (void)countDown;

/* 
 * Causes the current thread to wait until the latch has counted down to 0.
 * If the current count is zero then this method returns immediately.
 * If the current count is greater than zero then the current thread becomes disabled.
 */
- (void)await;

/*
 * If the time is less than or equal to zero, the method
 * will not wait at all.
 */
- (void)await:(dispatch_time_t)timeout;

@end
