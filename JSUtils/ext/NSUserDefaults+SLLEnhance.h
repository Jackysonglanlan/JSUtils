//
//  NSUserDefaults+SLLEnhance.h
//  SBFinance
//
//  Created by jacky.song on 12-11-8.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults(SLLEnhance)

@end


@interface NSString(NSUserDefaults_SLLEnhance)

-(void)jsSaveToUserDefaults:(NSString*)key;

-(NSString*)jsUseAsKeyToSearchUserDefaults;

@end


