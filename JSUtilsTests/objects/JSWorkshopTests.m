//
//  JSWorkshopTests.m
//  JSUtils
//
//  Created by jackysong on 14-12-3.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"
#import "JSWorkshop.h"

@interface JSWorkshopTests : AbstractTests

@end

@implementation JSWorkshopTests

- (void)testExample{
    JSPipeLine *line = [JSPipeLine new];
    [line installBlockUnit:^(id income, JSPipeLineContext *context) {
        NSNumber *count = income;
//        [context gotoStep:2 withData:@(count.integerValue+1)];
        [context next:@(count.integerValue+1)];
    }
               toStepIndex:0];
    
    [line installBlockUnit:^(id income, JSPipeLineContext *context) {
        NSNumber *count = income;
        [context next:@(count.integerValue*2)];
//        [context stop:@(count.integerValue*2)];
    }
               toStepIndex:1];

    [line installBlockUnit:^(id income, JSPipeLineContext *context) {
        NSNumber *count = income;
        [context next:@(count.integerValue-1)];
    }
               toStepIndex:2];
    
    JSWorkshop *shop = [JSWorkshop new];
    [shop addPipeLine:line forId:@"test"];
    
    [shop runPipeLineWithId:@"test" andInitData:@1 completion:^(id finalProduct) {
        NSLog(@"finalProduct: %@",finalProduct);
    }];
    
    [self beginAsyncOperationWithTimeout:10];
}

@end
