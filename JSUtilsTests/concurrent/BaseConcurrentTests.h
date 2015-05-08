//
//  BaseConcurrentTests.h
//  JSUtils
//
//  Created by Song Lanlan on 22/3/14.
//  Copyright (c) 2014 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"

#import "JSGCDDispatcher.h"
#import "CountDownLatch.h"

@interface BaseConcurrentTests : AbstractTests{
  // indicate whether the code has been run there
  int codeHitCount;
  int codeShouldHitCount;
  
  int timeoutInSeconds;
  
  // a count down latch to sync threads that run the test code.
  CountDownLatch *countDownLatch;
  
@protected
  JSGCDDispatcher *dispatcher;
}

// check whether the code has been run at the location where this method is invoked,
// usually this method is called by other threads
- (void)codeShouldReachHere;

// effectively equals to the total num. of times codeShouldReachHere is invoked.
- (void)setTotalCodeReachCount:(int)count;

- (void)setTimeout:(int)timeInSeconds;

@end
