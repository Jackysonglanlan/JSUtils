//
//  SystemManager.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-7-25.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "JSSystem.h"

@implementation JSSystem

+(void)doWhenIsIOS6:(void (^)(void))ios6Block{
    
    if (System_Ver_IOS6) {
        if (ios6Block) ios6Block();
    }
}

+(void)doWhenIsIOS7:(void (^)(void))ios7Block{
    if (System_Ver_IOS7_OR_LATER) {
        if (ios7Block) ios7Block();
    }
}

+(void)doWhenIsIOS6:(void (^)(void))ios6Block whenIsIOS7:(void (^)(void))ios7Block{
    [self doWhenIsIOS6:ios6Block];
    [self doWhenIsIOS7:ios7Block];
}

@end
