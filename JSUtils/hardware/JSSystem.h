//
//  SystemManager.h
//  CMGESocialSDK
//
//  Created by jackysong on 14-7-25.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define System_Ver_IOS7_OR_LATER   ([[[UIDevice currentDevice] systemVersion] intValue] >= 7)

#define System_Ver_IOS6   ([[[UIDevice currentDevice] systemVersion] intValue] >= 6 && !System_Ver_IOS7_OR_LATER)

@interface JSSystem : NSObject

+(void)doWhenIsIOS6:(void (^)(void))ios6Block whenIsIOS7:(void (^)(void))ios7Block;

+(void)doWhenIsIOS6:(void (^)(void))ios6Block;

+(void)doWhenIsIOS7:(void (^)(void))ios7Block;

@end
