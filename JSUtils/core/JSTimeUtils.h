//
//  JSTimeUtils.h
//
//  Created by jackysong on 11-1-29.
//  Copyright 2011 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSTimeUtils : NSObject {

}

/*
 Calculate time, return an int array -> [0]=day [1]=hour [2]=minute [3]=secend
 */
+(NSArray*)calculateTime:(NSTimeInterval)timeInMS;

#pragma mark human

+(NSString*)getHumanReadableWeekDay:(NSUInteger)weekDay;

+(NSString*)getHumanReadableTimeRangeFrom:(long long)fromSec1970 to:(long long)toSec1970;

+(NSString*)getHumanReadableTimeRangeFrom:(long long)fromSec1970 to:(long long)toSec1970 timeZone:(NSString*)timeZone;

+(NSString*)getHumanReadableDateRangeFrom:(long long)fromSec1970 to:(long long)toSec1970;

+(NSString*)getHumanReadableDate:(long long)sec1970;

@end
