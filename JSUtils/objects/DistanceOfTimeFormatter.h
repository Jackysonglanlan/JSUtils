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

#import <Foundation/Foundation.h>

typedef enum  {
  DistanceOfTime_Unit_MINUTE,
  DistanceOfTime_Unit_HOUR,
  DistanceOfTime_Unit_DAY,
  DistanceOfTime_Unit_WEEK,
  DistanceOfTime_Unit_MONTH,
  DistanceOfTime_Unit_YEAR,
}DistanceOfTime_Unit;

@interface DistanceOfTimeFormatter : NSObject

-(void)addRange:(NSRange)timeRangeInMin unit:(DistanceOfTime_Unit)unit
         prefix:(NSString*)prefix suffix:(NSString*)suffix displayNumber:(BOOL)displayNumber;

- (NSString *)distanceOfTimeInWords:(NSTimeInterval)secondsFrom1970;

@end
