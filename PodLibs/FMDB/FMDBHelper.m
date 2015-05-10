//
//  FMDBHelper.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-4-11.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "FMDBHelper.h"

@implementation FMDBHelper{
    FMDatabase *db;
}

- (id)initWithDBAtPath:(NSString*)path{
    self = [super init];
    if (self) {
        db = [[FMDatabase databaseWithPath:path] retain];
        if (![db open]) {
            JS_releaseSafely(db);
            JS_Stub_Throw(@"Fatal", @"Can't open constant data db:%@", path);
        }
    }
    return self;
}

- (void)dealloc{
    [db close];
    JS_releaseSafely(db);
    [super dealloc];
}

#pragma mark public

-(void)doWithStatement:(NSString*)stat process:(void (^)(FMResultSet *rs))block{
    FMResultSet *s = [db executeQuery:stat];
    while ([s next]) {
        block(s);
    }
}

-(void)doWithStatement:(NSString*)stat fields:(NSArray*)fields processRowData:(void (^)(NSDictionary *rawData))block{
    [self doWithStatement:stat process:^(FMResultSet *rs) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        if (fields) {
            [fields each:^(NSString *cName) {
                dic[cName] = [rs objectForColumnName:cName];
            }];
        }
        else{
            NSDictionary *map = [rs columnNameToIndexMap];

            [map eachKey:^(NSString *cName) {
                dic[cName] = [rs objectForColumnName:cName];
            }];
        }
        
        block(dic);
    }];
}

@end
