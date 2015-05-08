//
//  JSConstantsTest.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-22.
//  Copyright (c) 2012年 Cybercom. All rights reserved.
//

#import "AbstractTests.h"

@interface JSConstantsTest : AbstractTests @end

@implementation JSConstantsTest

- (void)testBitCalculation{
  assertThatInt(1 << 1, is(equalToInteger(2)));
  assertThatInt(1 << 2, is(equalToInteger(4)));
  assertThatInt(1 << 3, is(equalToInteger(8)));
  
  assertThatInt(2|4, is(equalToInteger(6)));
  assertThatInt(4|8, is(equalToInteger(12)));
}

- (void)testJS_IsContainsFlag{
  assertThatBool(JS_IsContainsFlag(6, 2), is(equalToBool(YES)));
  assertThatBool(JS_IsContainsFlag(6, 4), is(equalToBool(YES)));
  assertThatBool(JS_IsContainsFlag(6, 1), is(equalToBool(NO)));
  assertThatBool(JS_IsContainsFlag(6, 8), is(equalToBool(NO)));
  
}

@end
