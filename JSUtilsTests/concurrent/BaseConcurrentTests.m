//
//  BaseConcurrentTests.m
//  JSUtils
//
//  Created by Song Lanlan on 22/3/14.
//  Copyright (c) 2014 Jacky.Song. All rights reserved.
//

#import "BaseConcurrentTests.h"

@implementation BaseConcurrentTests

#pragma mark - utils

- (void)reset{
  codeHitCount = 0;
  codeShouldHitCount = 0;
  timeoutInSeconds = 5;
}

- (void)before{
  dispatcher = [JSGCDDispatcher sharedInstance];
  [self reset];
}

- (void)after{
  if (countDownLatch) {
    //    NSLog(@"%llu",NSEC_PER_SEC);
    // the main thread should be blocked here because there definitely have some threads are still working
    [countDownLatch await:dispatch_time(DISPATCH_TIME_NOW, timeoutInSeconds*NSEC_PER_SEC)];
  }
  
  // right here, the main thread should run again
  
  // check the code hit count
  assertThatInt(codeHitCount, equalToInt(codeShouldHitCount));
  
  [countDownLatch release];
}

#pragma mark fixture

- (void)codeShouldReachHere{
  @synchronized(self){
    codeHitCount++;
  }
  
  [countDownLatch countDown];
}

- (void)setTotalCodeReachCount:(int)count{
  // lazy loading
  if (count > 0) {
    codeShouldHitCount = count;
    countDownLatch = [[CountDownLatch alloc] initWithCount:count];
  }
}

- (void)setTimeout:(int)timeInSeconds{
  timeoutInSeconds = timeInSeconds;
}

@end
