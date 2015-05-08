//
//  Hardware.h
//  IDK
//
//  Created by jackysong on 14-5-4.
//  Copyright (c) 2014年 CMGE. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Device_IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)]\
                            && ([UIScreen mainScreen].scale == 2.0))

//#define Device_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568 ? YES : NO)

#define Device_IS_IPHONE  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)


@interface JSHardware : NSObject

+(NSString*)openUDID;

+(NSString*)identifierForVendor;

+ (NSInteger)screenHeight;

+ (NSInteger)screenWidth;

+ (NSString *)deviceModel;

+ (NSString *)deviceName;

+(NSString*)deviceType;

+ (NSString *)systemName;

+ (NSString *)systemVersion;

+(void)doWhenItsRetina:(void (^)(void))block;

+(void)doWhenItsIPhone:(void (^)(void))block;

+(NSString*)humanReadableDeviceType;

@end
