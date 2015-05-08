//
//  JSAudioUtils.h
//  JSUtils
//
//  Created by jackysong on 14-3-29.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSAudioUtils : NSObject

/**
 * @return -1 if can't get duration for some reasons.
 */
+(NSTimeInterval)getAMRDuration:(NSString*)amrFilePath;

@end
