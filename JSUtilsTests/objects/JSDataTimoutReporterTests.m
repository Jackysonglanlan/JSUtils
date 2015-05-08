//
//  ICEPkgResenderTests.m
//  CMGE-Core
//
//  Created by jackysong on 14-12-4.
//  Copyright (c) 2014年 cmge. All rights reserved.
//

#import "AbstractTests.h"

#import "JSDataTimoutReporter.h"

@interface JSDataTimoutReporterTests : AbstractTests

@end

@implementation JSDataTimoutReporterTests

- (void)testExample{
    JSDataTimoutReporter *reporter = [JSDataTimoutReporter new];
    
    reporter.timeoutAfterMarkInSec = 3;
    
    [reporter setDataDidTimeout:^(NSString *dataId, id data) {
        NSLog(@"%@ - %@",dataId, data);
    }];
    
    [reporter markData:@"aaa" withId:@"111"];

    sleep(2);
    
    [reporter markData:@"bbb" withId:@"222"];
    
    [self beginAsyncOperationWithTimeout:20];
}

@end
