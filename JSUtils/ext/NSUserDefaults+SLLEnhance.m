//
//  NSUserDefaults+SLLEnhance.m
//  SBFinance
//
//  Created by jacky.song on 12-11-8.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import "NSUserDefaults+SLLEnhance.h"

@implementation NSUserDefaults(SLLEnhance)

@end



@implementation NSString(NSUserDefaults_SLLEnhance)

-(void)jsSaveToUserDefaults:(NSString*)key{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [ud setObject:self forKey:key];
  [ud synchronize];
}

-(NSString*)jsUseAsKeyToSearchUserDefaults{
  return [[NSUserDefaults standardUserDefaults] objectForKey:self];
}

@end
