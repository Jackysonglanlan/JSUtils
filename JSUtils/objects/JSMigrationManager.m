//
//  JSMigrationManager.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-7-30.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "JSMigrationManager.h"

@implementation JSMigrationManager

static NSMutableDictionary *migrationActions;
+(void)initialize{
    if (self != JSMigrationManager.class) return;
    
    migrationActions = [[NSMutableDictionary alloc] initWithCapacity:5]; //
}

+(void)doStartMigrationFromVersion:(NSString*)fromVer{
    NSArray *sortedVersionNumList = [[migrationActions allKeys] sort];
    
    BOOL isNewestVersion = [[sortedVersionNumList lastObject] isEqualToString:fromVer];
    
    if (isNewestVersion) return;
    
    NSInteger startMigrationIndex = [sortedVersionNumList indexOfObject:fromVer];
    
    BOOL isNoMatchVersion = (startMigrationIndex == NSNotFound);
    if (isNoMatchVersion) JS_Stub_Throw(@"Fatal Migration Error !!", @"No migration version found:%@", fromVer);
    
    startMigrationIndex++; // skip the current version (no need to migrate)
    
    NSUInteger migrationCount = sortedVersionNumList.count - startMigrationIndex;
    
    NSArray *needToMigrateVersions = [sortedVersionNumList subarrayWithRange:
                                      NSMakeRange(startMigrationIndex, migrationCount)];
    
    // start migrating !
    [needToMigrateVersions eachWithIndex:^(NSString *key, NSUInteger index) {
        void (^action)(NSString *fromVer, NSString *toVer) = migrationActions[key];
        action(index == 0 ? fromVer : needToMigrateVersions[index-1], key);
    }];
}


#pragma mark - public

+(void)setStartVersion:(NSString*)versionNum{
    migrationActions[versionNum] = [[^{} copy] autorelease];
}

// versionNum format: x.x.x , for example: 1.2.11
+ (void) migrateToVersion:(NSString*)versionNum action:(void (^)(NSString *fromVer, NSString *toVer))action{
    migrationActions[versionNum] = [[action copy] autorelease];
}

// versionNum format: x.x.x , for example: 1.2.11
+(void)startMigrationFromVersion:(NSString*)fromVer completion:(void (^)(void))completion{
    [Executors dispatchAsync:DISPATCH_QUEUE_PRIORITY_HIGH task:^{
        [self doStartMigrationFromVersion:fromVer];
        if (completion) completion();
    }];
}

@end
