//
//  JSMessageBusSubscriber.m
//  JSUtils
//
//  Created by Song Lanlan on 1/5/15.
//  Copyright (c) 2015 Jacky.Song. All rights reserved.
//

#import "JSMessageBusSubscriber.h"

@implementation JSMessageBusSubscriber

- (void)dealloc{
    JS_releaseSafely(_willStartProcessingMessage);
    JS_releaseSafely(_messageFilter);
    JS_releaseSafely(_messageHandler);
    [super dealloc];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"subscriber[priority:%ld]", (long)self.priority];
}

@end
