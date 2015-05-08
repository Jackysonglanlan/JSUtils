//
//  JSBitsTests.m
//  JSUtils
//
//  Created by jackysong on 14-3-31.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"
#import "JSBits.h"

@interface JSBitsTests : AbstractTests

@end

@implementation JSBitsTests

- (void)testGetBitsValueFrom{
    uint64_t testValue = 123;
    [JSBits printInt16Bits:testValue];
    [JSBits printInt16Bits:[JSBits getBitsValueFrom:testValue validBitCount:8 range:NSMakeRange(2, 5)]];
}

@end
