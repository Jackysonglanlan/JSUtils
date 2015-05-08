//
//  PDLinkedListTests.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-23.
//  Copyright (c) 2012年 Cybercom. All rights reserved.
//

#import "AbstractTests.h"

@interface PDQueueTests : AbstractTests

@end

#import "PDQueue.h"

@implementation PDQueueTests

PDQueue *list = nil;

- (void)setUp{
  list = [[PDQueue alloc] init] ;
}

- (void)tearDown{
  JS_releaseSafely(list);
}

// All code under test must be linked into the Unit Test bundle
- (void)testPushAndPop{
  [list push:iObject(1)];
  [list push:iObject(3)];
  [list push:iObject(2)];
  
  assertThat([list pop], is(equalToInt(2)));
  assertThat([list pop], is(equalToInt(3)));
  assertThat([list pop], is(equalToInt(1)));
  assertThatInt([list size], is(equalToInt(0)));
}

- (void)testShiftAndUnshift{
  [list unshift:iObject(1)];
  [list unshift:iObject(3)];
  [list unshift:iObject(2)];
  
  assertThat([list shift], is(equalToInt(2)));
  assertThat([list shift], is(equalToInt(3)));
  assertThat([list shift], is(equalToInt(1)));
  assertThatInt([list size], is(equalToInt(0)));
}

- (void)testShiftAndPop{
  [list push:iObject(1)];
  [list push:iObject(3)];
  [list push:iObject(2)];
  [list push:iObject(4)];
  
  assertThat([list shift], is(equalToInt(1)));
  assertThat([list pop], is(equalToInt(4)));
  assertThat([list shift], is(equalToInt(3)));
  assertThatInt([list size], is(equalToInt(1)));
}

@end
