//
//  Hardware.m
//  IDK
//
//  Created by jackysong on 14-5-4.
//  Copyright (c) 2014年 CMGE. All rights reserved.
//

#import "JSHardware.h"

#import <sys/utsname.h>
#import "JSOpenUDID.h"

@implementation JSHardware

+(NSString*)openUDID{
    return [JSOpenUDID value];
}

+(NSString*)identifierForVendor{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        NSString *UUIDString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        return UUIDString;
    }
    
    return nil;

}

// Get the Screen Width (X)
+ (NSInteger)screenWidth {
    // Get the screen width
    @try {
        // Screen bounds
        CGRect Rect = [[UIScreen mainScreen] bounds];
        // Find the width (X)
        NSInteger Width = Rect.size.width;
        // Verify validity
        if (Width <= 0) {
            // Invalid Width
            return -1;
        }
        
        // Successful
        return Width;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Get the Screen Height (Y)
+ (NSInteger)screenHeight {
    // Get the screen height
    @try {
        // Screen bounds
        CGRect Rect = [[UIScreen mainScreen] bounds];
        // Find the Height (Y)
        NSInteger Height = Rect.size.height;
        // Verify validity
        if (Height <= 0) {
            // Invalid Height
            return -1;
        }
        
        // Successful
        return Height;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Model of Device
+ (NSString *)deviceModel {
    // Get the device model
    if ([[UIDevice currentDevice] respondsToSelector:@selector(model)]) {
        // Make a string for the device model
        NSString *deviceModel = [[UIDevice currentDevice] model];
        // Set the output to the device model
        return deviceModel;
    }
    return nil;
}

// Device Name
+ (NSString *)deviceName {
    // Get the current device name
    if ([[UIDevice currentDevice] respondsToSelector:@selector(name)]) {
        // Make a string for the device name
        NSString *deviceName = [[UIDevice currentDevice] name];
        // Set the output to the device name
        return deviceName;
    }
    return nil;
}

+(NSString*)deviceType{
    struct utsname DT;
    // Get the system information
    uname(&DT);
    // Set the device type to the machine type
    NSString *deviceType = [NSString stringWithFormat:@"%s", DT.machine];
    return deviceType;
}

// System Name
+ (NSString *)systemName {
    // Get the current system name
    if ([[UIDevice currentDevice] respondsToSelector:@selector(systemName)]) {
        // Make a string for the system name
        NSString *systemName = [[UIDevice currentDevice] systemName];
        // Set the output to the system name
        return systemName;
    }
    return nil;
}

// System Version
+ (NSString *)systemVersion {
    // Get the current system version
    if ([[UIDevice currentDevice] respondsToSelector:@selector(systemVersion)]) {
        // Make a string for the system version
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        // Set the output to the system version
        return systemVersion;
    }
    return nil;
}

+(void)doWhenItsRetina:(void (^)(void))block{
    if (Device_IS_RETINA) {
        if (block) block();
    }
}

+(void)doWhenItsIPhone:(void (^)(void))block{
    if (Device_IS_IPHONE) {
        if (block) block();
    }
}

+(NSString*)humanReadableDeviceType{
    NSDictionary *deviceMap = @{@"iPhone1,1": @"iPhone",
                                @"iPhone1,2": @"iPhone3G",
                                @"iPhone2,1": @"iPhone3GS",
                                @"iPhone3,1": @"iPhone4",
                                @"iPhone3,2": @"iPhone4",
                                @"iPhone3,3": @"iPhone4",
                                @"iPhone4,1": @"iPhone4S",
                                @"iPhone5,1": @"iPhone5",
                                @"iPhone5,2": @"iPhone5",
                                @"iPhone5,3": @"iPhone5C",
                                @"iPhone5,4": @"iPhone5C",
                                @"iPhone6,1": @"iPhone5S",
                                @"iPhone6,2": @"iPhone5S",
                                @"iPad1,1": @"iPad1",
                                @"iPad2,1": @"iPad2",
                                @"iPad2,2": @"iPad2",
                                @"iPad2,3": @"iPad2",
                                @"iPad2,4": @"iPad2",
                                @"iPad2,5": @"iPad mini",
                                @"iPad2,6": @"iPad mini",
                                @"iPad2,7": @"iPad mini",
                                @"iPad3,1": @"iPad3",
                                @"iPad3,2": @"iPad3",
                                @"iPad3,3": @"iPad3",
                                @"iPad3,4": @"iPad4",
                                @"iPad3,5": @"iPad4",
                                @"iPad3,6": @"iPad4",
                                @"iPod1,1": @"iPod touch",
                                @"iPod2,1": @"iPod touch2",
                                @"iPod3,1": @"iPod touch3",
                                @"iPod4,1": @"iPod touch4",
                                @"iPod5,1": @"iPod touch5"};
    
    NSString *type = [self deviceType];
    
    return deviceMap[type];
}

@end
