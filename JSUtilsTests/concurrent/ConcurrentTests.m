//
//  ConcurrentTests.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-27.
//  Copyright (c) 2012年 Cybercom. All rights reserved.
//

#import "BaseConcurrentTests.h"

@interface ConcurrentTests : BaseConcurrentTests

@end

@implementation ConcurrentTests

- (void)testDispatch{
  [self setTotalCodeReachCount:1];

  [dispatcher dispatchAsync:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));
    [self codeShouldReachHere];
  }];
  
}

- (void)testDispatchPriority{
  [self setTotalCodeReachCount:3];
  
  [dispatcher dispatchAsync:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));    
    [self codeShouldReachHere];
  } priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];

  [dispatcher dispatchAsync:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));    
    [self codeShouldReachHere];
  } priority:DISPATCH_QUEUE_PRIORITY_HIGH];
  
  [dispatcher dispatchAsync:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));    
    [self codeShouldReachHere];
  } priority:DISPATCH_QUEUE_PRIORITY_LOW];
  
}

- (void)testDispatchOnSerialQueue{
  [self setTotalCodeReachCount:5];

  // simulate ((4 + 3) * 2 + 2) / 2
  
  __block int sum = 4;
  
  [dispatcher dispatchOnSerialQueue:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));
    sum += 3;
    [self codeShouldReachHere];
  }];
  
  [dispatcher dispatchOnSerialQueue:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));
    sum *= 2;
    [self codeShouldReachHere];
  }];

  [dispatcher dispatchOnSerialQueue:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));
    sum += 2;
    [self codeShouldReachHere];
  }];

  [dispatcher dispatchOnSerialQueue:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));
    sum /= 2;
    [self codeShouldReachHere];
  }];

  [dispatcher dispatchOnSerialQueue:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(NO)));

    // check the result
    assertThatInt(sum, is(equalToInt(8)));
    [self codeShouldReachHere];
  }];

}

- (void)testDispatchOnMainThread{
  [dispatcher dispatchSyncOnMainThread:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(YES)));
  }];

  [dispatcher dispatchAsyncOnMainThread:^{
    assertThatBool([[NSThread currentThread] isMainThread], is(equalToBool(YES)));
  }];
  // the same effect as NO block
}

@end
