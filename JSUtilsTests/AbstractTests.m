//
//  AbstractTests.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-27.
//  Copyright (c) 2012年 Cybercom. All rights reserved.
//

#import "AbstractTests.h"

@implementation AbstractTests{
  dispatch_semaphore_t _networkSemaphore;
  BOOL _didTimeout;
}

#pragma mark - life cycle

- (void)before{
  
}

- (void)after{
  
}

#pragma mark - utils

-(NSBundle*)testBundle{
    return [NSBundle bundleWithIdentifier:@"jacky.song.JSUtilsTests"];
}

- (void)beginAsyncOperation{
  _didTimeout = NO;
  _networkSemaphore = dispatch_semaphore_create(0);
}

- (void)beginAsyncOperationWithTimeout:(NSTimeInterval)timeout{
    [self beginAsyncOperation];
    [self waitForAsyncOperationOrTimeoutWithInterval:timeout];
}

- (void)finishedAsyncOperation{
  _didTimeout = NO;
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutAsyncOperation) object:nil];
  
  dispatch_semaphore_signal(_networkSemaphore);
  dispatch_release(_networkSemaphore);
}

- (BOOL)waitForAsyncOperationOrTimeoutWithDefaultInterval{
  return [self waitForAsyncOperationOrTimeoutWithInterval:10];
}

- (BOOL)waitForAsyncOperationOrTimeoutWithInterval:(NSTimeInterval)interval{
  [self performSelector:@selector(timeoutAsyncOperation) withObject:nil afterDelay:interval];
  
  // wait for the semaphore to be signaled (triggered)
  while (dispatch_semaphore_wait(_networkSemaphore, DISPATCH_TIME_NOW)){
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
  }
  
  return _didTimeout;
}

- (void)timeoutAsyncOperation{
  _didTimeout = YES;
  dispatch_semaphore_signal(_networkSemaphore);
  dispatch_release(_networkSemaphore);
  XCTFail(@"Async operation timed out."); // auto-fail
}

- (void)assertAsyncOperationTimeout{
  assertThatBool([self waitForAsyncOperationOrTimeoutWithDefaultInterval], equalToBool(NO));
}

- (void)setUp{
  [self before];
}

- (void)tearDown{
  [self after];
}

@end
