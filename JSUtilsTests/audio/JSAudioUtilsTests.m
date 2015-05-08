//
//  JSAudioUtilsTests.m
//  JSUtils
//
//  Created by jackysong on 14-3-29.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"
#import "JSAudioUtils.h"

@interface JSAudioUtilsTests : AbstractTests

@end

@implementation JSAudioUtilsTests{
    
}

- (void)testGetAMRDuration{
    NSString *amrPath = [[[self testBundle] URLForResource:@"testAMR" withExtension:@"amr"] path];
    
    NSTimeInterval duration = [JSAudioUtils getAMRDuration:amrPath];
    
    assertThatFloat(duration, closeTo(17.92, 0.1));
}

@end
