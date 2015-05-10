//
//  DBSource.h
//  QMQZ
//
//  Created by admin on 15/1/13.
//  Copyright (c) 2015年 cmge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKKeyValueStore.h"

/**
 * Key-Value sqlite DB access class.
 */
@interface KVStoreSource : NSObject

@property(nonatomic,readonly) YTKKeyValueStore *store;

- (instancetype)initWithDBPath:(NSString*)path;

- (void)putString:(NSString *)string needEncrpty:(BOOL)yesToEnc withId:(NSString *)stringId intoTable:(NSString *)tableName ;
    - (NSString *)getStringById:(NSString *)stringId needDecrpty:(BOOL)yesToDec fromTable:(NSString *)tableName ;

- (void)saveObject:(id)obj forKey:(NSString*)key table:(NSString*)table;
- (id)getObjectForKey:(NSString*)key table:(NSString*)table;

- (void)saveNumber:(NSNumber*)num forKey:(NSString*)key table:(NSString*)table;
- (NSNumber*)getNumberForKey:(NSString*)key table:(NSString*)table;

@end
