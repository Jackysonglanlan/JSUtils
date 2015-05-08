//
//  JSLocationUtils.h
//  TianTian
//
//  Created by Song Lanlan on 13-11-2.
//  Copyright (c) 2013年 tiantian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface JSLocationUtils : NSObject

+ (NSString*)stringFromCLLocationCoordinate2D:(CLLocationCoordinate2D)point;

+ (CLLocationCoordinate2D)clLocationCoordinate2DFromString:(NSString*)string;

@end
