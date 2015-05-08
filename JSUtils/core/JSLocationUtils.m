//
//  JSLocationUtils.m
//  TianTian
//
//  Created by Song Lanlan on 13-11-2.
//  Copyright (c) 2013年 tiantian. All rights reserved.
//

#import "JSLocationUtils.h"
#import "NSString+SLLEnhance.h"
#import "RegexKitLite.h"

@implementation JSLocationUtils

+(NSString*)stringFromCLLocationCoordinate2D:(CLLocationCoordinate2D)point{
  return [NSString stringWithFormat:@"{%f,%f}",point.latitude,point.longitude];
}

+(CLLocationCoordinate2D)clLocationCoordinate2DFromString:(NSString*)string{
  if (![string isMatchedByRegex:@"\\{\\d+(\\.\\d+)?,\\d+(\\.\\d+)?\\}"]) {
    return CLLocationCoordinate2DMake(0, 0);
  }
  
  // remove '{' '}'
  string = [string replaceAll:@"[\\{\\}]" with:@""];
  
  NSArray *tmp = [string componentsSeparatedByString:@","];
  
  return CLLocationCoordinate2DMake([(NSString*)tmp[0] doubleValue], [(NSString*)tmp[1] doubleValue]);
}

@end
