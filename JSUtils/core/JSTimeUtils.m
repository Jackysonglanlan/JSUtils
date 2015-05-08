//
//  JSTimeUtils.m
//
//  Created by jackysong on 11-1-29.
//  Copyright 2011 Jacky.Song. All rights reserved.
//

#import "JSTimeUtils.h"
#import "NSDate-Utilities.h"

@implementation JSTimeUtils

#pragma mark calculation

+(NSArray*)calculateTime:(NSTimeInterval)timeInMS{
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:4];
	
	NSUInteger sec = timeInMS/1000;
	
	NSUInteger min = 60;
	NSUInteger hour = min*60;
	NSUInteger day = hour*24;
	
	NSUInteger nDay = sec/day;
	[arr addObject:[NSNumber numberWithUnsignedLong:nDay]];
	sec -= nDay * day;
	NSUInteger nHour = sec/hour;
	[arr addObject:[NSNumber numberWithUnsignedLong:nHour]];
	sec -= nHour * hour;
	NSUInteger nMin = sec/min;
	[arr addObject:[NSNumber numberWithUnsignedLong:nMin]];
	sec -= nMin * min;
	[arr addObject:[NSNumber numberWithUnsignedLong:sec]];
	
	return [NSArray arrayWithArray:arr];
}

#pragma mark human

+(NSString*)getHumanReadableWeekDay:(NSUInteger)weekDay{
  switch (weekDay) {
    case 1:
      return @"日";
    case 2:
      return @"一";
    case 3:
      return @"二";
    case 4:
      return @"三";
    case 5:
      return @"四";
    case 6:
      return @"五";
    case 7:
      return @"六";
  }
  return nil;
}

+(NSString*)getHumanReadableTimeRangeFrom:(long long)fromSec to:(long long)toSec{
  return [JSTimeUtils getHumanReadableTimeRangeFrom:fromSec to:toSec timeZone:@"Asia/Shanghai"];
}

+(NSString*)getHumanReadableTimeRangeFrom:(long long)fromSec to:(long long)toSec timeZone:(NSString*)timeZone{
  NSDate *from = [NSDate dateWithTimeIntervalSince1970:fromSec];
  NSDate *to = [NSDate dateWithTimeIntervalSince1970:toSec];
  
  // set timezone
  NSTimeZone *defaultZone = [NSTimeZone defaultTimeZone];
  [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:timeZone]];
  
  NSInteger fromWeekDay = from.weekday;
  NSInteger toWeekDay = to.weekday;
  
  NSMutableString *readableTimeRange = [NSMutableString string];
  
  [readableTimeRange appendFormat:@"周%@", [self getHumanReadableWeekDay:fromWeekDay]];
  
  if (from.day != to.day) {
    [readableTimeRange appendString:@" 到 "];
    [readableTimeRange appendFormat:@"周%@", [self getHumanReadableWeekDay:toWeekDay]];
  }
  [readableTimeRange appendString:@" "];
  [readableTimeRange appendFormat:@"%02ld:%02ld",(long)from.hour,(long)from.minute];
  [readableTimeRange appendString:@" - "];
  [readableTimeRange appendFormat:@"%02ld:%02ld",(long)to.hour,(long)to.minute];
  
  // recover timezone
  [NSTimeZone setDefaultTimeZone:defaultZone];
  
  return readableTimeRange;
}

+(NSString*)getHumanReadableDateRangeFrom:(long long)fromSec to:(long long)toSec{
  NSDate *from = [NSDate dateWithTimeIntervalSince1970:fromSec];
  NSDate *to = [NSDate dateWithTimeIntervalSince1970:toSec];
  
  NSMutableString *readableRange = [NSMutableString string];
  
  [readableRange appendFormat:@"%ld.%02ld.%02ld",(long)from.year, (long)from.month,(long)from.day];
  if (from.day != to.day) {
    [readableRange appendString:@" - "];
    [readableRange appendFormat:@"%ld.%02ld.%02ld",(long)from.year, (long)from.month,(long)from.day];
  }
  
  return readableRange;
}

+(NSString*)getHumanReadableDate:(long long)sec1970{
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:sec1970];
  
  if ([date isToday]) {
    return @"今天";
  }
  
  if ([date isYesterday]) {
    return @"昨天";
  }
  
  return [NSString stringWithFormat:@"%02ld.%02ld", (long)date.month, (long)date.day];
}

#pragma mark time status



@end
