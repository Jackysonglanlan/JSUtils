//
//  JSGCDLoopRunnerTests.m
//  JSUtils
//
//  Created by jackysong on 14-9-30.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"
#import "JSGCDLoopRunner.h"

@interface JSGCDLoopRunnerTests : AbstractTests

@end

@implementation JSGCDLoopRunnerTests{
    JSGCDLoopRunner *runner;
}

-(void)before{
    runner = [JSGCDLoopRunner new];
}

-(void)after{
    JS_releaseSafely(runner);
}

- (void)testLogic{
    __block int count = 0;
    
    JS_weakReferBlock(*&runner) weakRunner = runner;
     
    [runner addLoopingWithName:@"aaa" interval:1 task:^{
        NSLog(@"%d", count);
        if (++count == 3) {
            [weakRunner addLoopingWithName:@"bbb" interval:1 task:^{
                NSLog(@"sssss");
            }];
        }
        
        if (count == 8) {
            [weakRunner removeLooping:@"aaa"];
        }
    }];
    
    [self beginAsyncOperationWithTimeout:100];
}

@end
