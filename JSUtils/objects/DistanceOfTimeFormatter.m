//
//  Copyright 2011 Rob Warner
//  @hoop33
//  rwarner@grailbox.com
//  http://grailbox.com


//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "DistanceOfTimeFormatter.h"
#import "JSMacros.h"

#define SECONDS_PER_MINUTE 60.0
#define SECONDS_PER_HOUR   3600.0
#define SECONDS_PER_DAY    86400.0
#define SECONDS_PER_MONTH  2592000.0
#define SECONDS_PER_YEAR   31536000.0

@implementation DistanceOfTimeFormatter{
  NSMutableDictionary *rangeUnitMap;
  NSMutableDictionary *rangeFormatStyleMap;
}

- (id)init{
  self = [super init];
  if (self) {
    rangeUnitMap = [[NSMutableDictionary alloc] init];
    rangeFormatStyleMap = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc{
  JS_releaseSafely(rangeUnitMap);
  JS_releaseSafely(rangeFormatStyleMap);
  [super dealloc];
}

-(void)addRange:(NSRange)timeRange unit:(DistanceOfTime_Unit)unit
         prefix:(NSString*)prefix suffix:(NSString*)suffix displayNumber:(BOOL)displayNumber{
  int multipy = 0;
  
  switch (unit) {
    case DistanceOfTime_Unit_MINUTE:
      multipy = SECONDS_PER_MINUTE / 60;
      break;
    case DistanceOfTime_Unit_HOUR:
      multipy = SECONDS_PER_HOUR / 60;
      break;
    case DistanceOfTime_Unit_DAY:
      multipy = SECONDS_PER_DAY / 60;
      break;
    case DistanceOfTime_Unit_WEEK:
      multipy = (SECONDS_PER_DAY / 60) * 7;
      break;
    case DistanceOfTime_Unit_MONTH:
      multipy = SECONDS_PER_MONTH / 60;
      break;
    case DistanceOfTime_Unit_YEAR:
      multipy = SECONDS_PER_YEAR / 60;
      break;
      
    default:
      break;
  }
  
  NSString *range = NSStringFromRange(NSMakeRange(timeRange.location*multipy, timeRange.length*multipy));
  rangeUnitMap[range] = @(unit);
  rangeFormatStyleMap[range] = [NSString stringWithFormat:displayNumber ? @"%@%%d%@" : @"%@%@",prefix,suffix];
}

- (NSString *)distanceOfTimeInWords:(NSTimeInterval)secondsFrom1970 {
  NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
  NSTimeInterval since = now - secondsFrom1970;
  
  // if it's future time, pull it back to now
  since = MAX(0, since);
  
//  int seconds   = (int)since;
  int minutes   = (int)round(since / SECONDS_PER_MINUTE);
  int hours     = (int)round(since / SECONDS_PER_HOUR);
  int days      = (int)round(since / SECONDS_PER_DAY);
  int months    = (int)round(since / SECONDS_PER_MONTH);
  int years     = (int)round(since / SECONDS_PER_YEAR);
//  int offset    = (int)round(floor((float)years / 4.0) * 1440.0);
//  int remainder = (minutes - offset) % 525600;
  
  int number = -1;
  NSString *fmtStyle = nil;
  for (NSString *strRange in [rangeUnitMap allKeys]) {
    NSRange timeRange = NSRangeFromString(strRange);
    if ((timeRange.location <= minutes) && (minutes <= timeRange.length)) {
      DistanceOfTime_Unit unit = intValue(rangeUnitMap[strRange]);
      fmtStyle = rangeFormatStyleMap[strRange];
      switch (unit) {
        case DistanceOfTime_Unit_MINUTE:{
          number = minutes;
        }
          break;
        case DistanceOfTime_Unit_HOUR:{
          number = hours;
        }
          break;
        case DistanceOfTime_Unit_DAY:{
          number = days;
        }
          break;
        case DistanceOfTime_Unit_WEEK:{
          number = days/7;
        }
          break;
        case DistanceOfTime_Unit_MONTH:{
          number = months;
        }
          break;
        case DistanceOfTime_Unit_YEAR:{
          number = years;
        }
          break;
          
        default:
          break;
      }
    }
  }
  
  if (number != -1) {
    return [NSString stringWithFormat:fmtStyle, number];
  }
  
  return nil;

  // original
  /*
  NSTimeInterval since = [self timeIntervalSinceDate:date];
  NSString *direction = since <= 0.0 ? Ago : FromNow;
  since = fabs(since);
  
  int seconds   = (int)since;
  int minutes   = (int)round(since / SECONDS_PER_MINUTE);
  int hours     = (int)round(since / SECONDS_PER_HOUR);
  int days      = (int)round(since / SECONDS_PER_DAY);
  int months    = (int)round(since / SECONDS_PER_MONTH);
  int years     = (int)floor(since / SECONDS_PER_YEAR);
  int offset    = (int)round(floor((float)years / 4.0) * 1440.0);
  int remainder = (minutes - offset) % 525600;
  
  int number;
  NSString *measure;
  NSString *modifier = @"";
  
  switch (minutes) {
    case 0 ... 1:
      measure = Seconds;
      switch (seconds) {
        case 0 ... 4:
          number = 5;
          modifier = LessThan;
          break;
        case 5 ... 9:
          number = 10;
          modifier = LessThan;
          break;
        case 10 ... 19:
          number = 20;
          modifier = LessThan;
          break;
        case 20 ... 39:
          number = 30;
          modifier = About;
          break;
        case 40 ... 59:
          number = 1;
          measure = Minute;
          modifier = LessThan;
          break;
        default:
          number = 1;
          measure = Minute;
          modifier = About;
          break;
      }
      break;
    case 2 ... 44:
      number = minutes;
      measure = Minutes;
      break;
    case 45 ... 89:
      number = 1;
      measure = Hour;
      modifier = About;
      break;
    case 90 ... 1439:
      number = hours;
      measure = Hours;
      modifier = About;
      break;
    case 1440 ... 2529:
      number = 1;
      measure = Day;
      break;
    case 2530 ... 43199:
      number = days;
      measure = Days;
      break;
    case 43200 ... 86399:
      number = 1;
      measure = Month;
      modifier = About;
      break;
    case 86400 ... 525599:
      number = months;
      measure = Months;
      break;
    default:
      number = years;
      measure = number == 1 ? Year : Years;
      if (remainder < 131400) {
        modifier = About;
      } else if (remainder < 394200) {
        modifier = Over;
      } else {
        ++number;
        measure = Years;
        modifier = Almost;
      }
      break;
  }
  */
}

@end
