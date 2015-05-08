//
//  JSLogUtils.m
//
//  Created by jackysong on 10-11-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JSLogUtils.h"

@implementation JSLogUtils

static void (^logger)(NSString *className, int line, NSString *content);

+(void)initialize{
    if (self != JSLogUtils.class) return;
    [self enable:YES];
}

+(void)enable:(BOOL)enable{
    [logger release];
    logger = nil;
    
    logger = enable ?
    
    [^(NSString *className, int line, NSString *content) {
        NSLog( @"<%@:%d> %@", className, line, content);
    } copy]
    
    :
    
    [^(NSString *className, int line, NSString *content) {} copy];
}

+(void)log:(NSString*)className line:(int)line content:(NSString*)content{
    logger(className,line,content);
}

@end

////////////////////////////////////////
/////// NSObject Enhancement ////////
////////////////////////////////////////

#pragma mark - NSObject Enhancement

@implementation NSObject(NSObject_JSLogUtils)

-(void)log{
  DLog(@"%@",self);
}

@end
