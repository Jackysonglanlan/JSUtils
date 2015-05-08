//
//  JSMigrationManager.h
//  CMGESocialSDK
//
//  Created by jackysong on 14-7-30.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSMigrationManager : NSObject

// versionNum format: x.x.x , for example: 1.2.11
+(void)setStartVersion:(NSString*)versionNum;

// versionNum format: x.x.x , for example: 1.2.11
+ (void) migrateToVersion:(NSString*)versionNum action:(void (^)(NSString *fromVer, NSString *toVer))action;

// versionNum format: x.x.x , for example: 1.2.11
+(void)startMigrationFromVersion:(NSString*)fromVer completion:(void (^)(void))completion;

@end
