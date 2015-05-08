//
//  CountDownLatch.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-4-6.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import "CountDownLatch.h"

@implementation CountDownLatch

- (id)initWithCount:(NSUInteger)count{
  if (self = [super init]) {
    counter = count;
    semaphore = dispatch_semaphore_create(0);// start with 0, then all the threads are blocked at the begining.
  }
  return self;
}

- (void)countDown{
  @synchronized(self){
    counter--;// count down the counter
  }

  BOOL isReadyToGo = (counter <= 0);
  // countDown <= 0 means all the threads have fininshed their work
  if (isReadyToGo) {
    dispatch_semaphore_signal(semaphore);
  }
}

- (void)await{
  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)await:(dispatch_time_t)timeout{
  dispatch_semaphore_wait(semaphore, timeout);
}

@end
