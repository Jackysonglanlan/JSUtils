//
//  DBSource.m
//  QMQZ
//
//  Created by admin on 15/1/13.
//  Copyright (c) 2015年 cmge. All rights reserved.
//

#import "KVStoreSource.h"

#import "EncryptUtils.h"

@implementation KVStoreSource
@synthesize store;

- (instancetype)initWithDBPath:(NSString*)path{
    self = [super init];
    if (self) {
        store = [[YTKKeyValueStore alloc] initWithDBWithPath:path];
    }
    return self;
}

- (void)dealloc{
    [store close];
    JS_releaseSafely(store);
    [super dealloc];
}

#pragma mark public

- (void)putString:(NSString *)string needEncrpty:(BOOL)yesToEnc withId:(NSString *)stringId intoTable:(NSString *)tableName {
    string = yesToEnc ? [EncryptUtils encrptyStringUsingAES256:string] : string;
    [store putString:string withId:stringId intoTable:tableName];
}

- (NSString *)getStringById:(NSString *)stringId needDecrpty:(BOOL)yesToDec fromTable:(NSString *)tableName {
    NSString *stringInDB = [store getStringById:stringId fromTable:tableName];
    return yesToDec ? [EncryptUtils decryptStringUsingAES256FromEncryptString:stringInDB] : stringInDB;
}

- (void)saveObject:(id)obj forKey:(NSString*)key table:(NSString*)table{
    [store putObject:obj withId:key intoTable:table];
}
- (id)getObjectForKey:(NSString*)key table:(NSString*)table {
    return [store getObjectById:key fromTable:table];
}

- (void)saveNumber:(NSNumber*)num forKey:(NSString*)key table:(NSString*)table{
    [store putNumber:num withId:key intoTable:table];
}
- (NSNumber*)getNumberForKey:(NSString*)key table:(NSString*)table {
    return [store getNumberById:key fromTable:table];
}

@end
