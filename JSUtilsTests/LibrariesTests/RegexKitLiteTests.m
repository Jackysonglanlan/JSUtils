//
//  RegexKitLiteTests.m
//  JSUtils
//
//  Created by Song Lanlan on 8/5/15.
//  Copyright (c) 2015 Song Lanlan. All rights reserved.
//

#import "AbstractTests.h"

@interface RegexKitLiteTests : AbstractTests

@end

@implementation RegexKitLiteTests

- (void)testExample{
    NSString *str = @"abc_456_0987";
    
    NSArray *result = [str componentsMatchedByRegex:@"(.*?)_" capture:1];
    
    DLog(@"%@",result);
    
}

@end
