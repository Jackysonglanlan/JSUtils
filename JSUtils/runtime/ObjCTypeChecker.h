//
//  ObjCTypeChecker.h
//  Labrary
//
//  Created by jacky.song on 13-3-27.
//  Copyright (c) 2013 symbio.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjCTypeChecker : NSObject

// You should use the type id here to lookup.
+(NSArray*)allTypeIds;

+(BOOL)isTypeId:(NSString*)tId matches:(NSString*)type;

+(NSString*)idOfType:(NSString*)tId;

@end
