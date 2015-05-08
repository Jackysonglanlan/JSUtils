//
//  JSMigrationManagerTests.m
//  JSUtils
//
//  Created by jackysong on 14-7-31.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"
#import "JSMigrationManager.h"

@interface JSMigrationManagerTests : AbstractTests

@end

@implementation JSMigrationManagerTests

- (void)testMigrationManager {
    [JSMigrationManager setStartVersion:@"1.0.0"];
    
    [JSMigrationManager migrateToVersion:@"1.0.1" action:^(NSString *fromVer, NSString *toVer) {
        NSLog(@"from %@ to %@", fromVer, toVer);
    }];
    
    [JSMigrationManager migrateToVersion:@"1.0.2" action:^(NSString *fromVer, NSString *toVer){
        NSLog(@"from %@ to %@", fromVer, toVer);
    }];
    
    [JSMigrationManager migrateToVersion:@"1.0.3" action:^(NSString *fromVer, NSString *toVer){
        NSLog(@"from %@ to %@", fromVer, toVer);
    }];
    
    [JSMigrationManager migrateToVersion:@"1.1" action:^(NSString *fromVer, NSString *toVer){
        NSLog(@"from %@ to %@", fromVer, toVer);
    }];
    
    [JSMigrationManager startMigrationFromVersion:@"1.0.0" completion:^{
        [self finishedAsyncOperation];
    }];
    
    [self beginAsyncOperationWithTimeout:5];
}

@end
