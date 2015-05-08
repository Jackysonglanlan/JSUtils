//
//  JSGCDLoopRunner.h
//  JSUtils
//
//  Created by jackysong on 14-9-30.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSGCDLoopRunner : NSObject

-(void)addLoopingWithName:(NSString*)name interval:(NSTimeInterval)seconds task:(void (^)(void))block;

-(void)removeLooping:(NSString*)name;

@end
