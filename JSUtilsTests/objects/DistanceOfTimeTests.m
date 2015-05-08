//
//  DistanceOfTimeTests.m
//  FastTest
//
//  Created by Song Lanlan on 13-10-7.
//  Copyright (c) 2013年 tiantian. All rights reserved.
//

#import "AbstractTests.h"
#import "DistanceOfTimeFormatter.h"

@interface DistanceOfTimeTests : AbstractTests

@end


@implementation DistanceOfTimeTests{
  DistanceOfTimeFormatter *fmtter;
}

-(void)before{
  fmtter = [DistanceOfTimeFormatter new];
  [fmtter addRange:NSMakeRange(0, 1) unit:(DistanceOfTime_Unit_MINUTE) prefix:@"" suffix:@"刚刚" displayNumber:NO];
  [fmtter addRange:NSMakeRange(1, 10) unit:(DistanceOfTime_Unit_MINUTE) prefix:@"大约" suffix:@"分钟前" displayNumber:YES];
  [fmtter addRange:NSMakeRange(11, 30) unit:(DistanceOfTime_Unit_MINUTE) prefix:@"大约" suffix:@"半小时前" displayNumber:NO];
  [fmtter addRange:NSMakeRange(1, 4) unit:(DistanceOfTime_Unit_HOUR) prefix:@"" suffix:@"小时前" displayNumber:YES];
  [fmtter addRange:NSMakeRange(1, 2) unit:(DistanceOfTime_Unit_WEEK) prefix:@"" suffix:@"周前" displayNumber:YES];
}

-(void)testFormat{
  assertThat([fmtter distanceOfTimeInWords:[[NSDate dateWithMinutesFromNow:5] timeIntervalSince1970]],
             is(@"刚刚"));
    
  assertThat([fmtter distanceOfTimeInWords:[[NSDate dateWithMinutesBeforeNow:5] timeIntervalSince1970]],
             is(@"大约5分钟前"));
    
  assertThat([fmtter distanceOfTimeInWords:[[NSDate dateWithMinutesBeforeNow:25] timeIntervalSince1970]],
             is(@"大约半小时前"));
    
  assertThat([fmtter distanceOfTimeInWords:[[NSDate dateWithHoursBeforeNow:2] timeIntervalSince1970]],
             is(@"2小时前"));
    
  assertThat([fmtter distanceOfTimeInWords:[[NSDate dateWithDaysBeforeNow:14] timeIntervalSince1970]],
             is(@"2周前"));
}

@end
