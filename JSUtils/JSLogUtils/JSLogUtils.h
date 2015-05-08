//
//  JSLogUtils.h
//
//  Created by jackysong on 10-11-19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSLogUtils : NSObject

+(void)enable:(BOOL)enable;

+(void)log:(NSString*)className line:(int)line content:(NSString*)content;

@end

////////////////////////////////////////
/////// NSObject Enhancement ////////
////////////////////////////////////////

@interface NSObject(NSObject_JSLogUtils) 

/*
 Log the object itself.
 */
-(void)log;

@end
