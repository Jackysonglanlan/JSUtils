//
//  BaseEntity.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-3-11.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "ActiveRecordEntity.h"
#import "ARDatabaseManager.h"

@implementation ActiveRecordEntity

- (id)init{
    self = [super init];
    if (self) {
        self.extraInfo = [NSMutableDictionary dictionaryWithCapacity:7];
    }
    return self;
}

-(void)dealloc{
    JS_releaseSafely(_extraInfo);
    [super dealloc];
}

#pragma mark private

+(ARLazyFetcher*)buildFetcherWithFrom:(NSTimeInterval)fromSec1970 to:(NSTimeInterval)toSec1970{
    NSString *state = [NSString stringWithFormat:@"createdAt >= %f and createdAt <= %f", fromSec1970, toSec1970];
    return [self buildFetcherFromStatement:state];
}

#pragma mark public

+(void)executeStatement:(NSString*)statement{
    [[ARDatabaseManager sharedInstance] executeSqlQuery:[statement UTF8String]];
}

+(ARLazyFetcher*)buildFetcherFromStatement:(NSString*)state{
    ARWhereStatement *where = [[ARWhereStatement alloc] initWithStatement:state];
    ARLazyFetcher *f = [self lazyFetcher];
    f.whereStatement = where;
    [where release];
//    DLog(@"Build fetcher from SQL:%@",state);
    return f;
}

#pragma mark find and count

+(id)findOneWithStatement:(NSString*)statement{
    ARLazyFetcher *f = [self buildFetcherFromStatement:statement];
    return [f jsFetchOne];
}

+(NSArray*)findAllInList:(NSArray*)values fieldName:(NSString*)field{
    NSString *sql = [NSString stringWithFormat:@"%@ in (%@)", field, [values join:@","]];
    return [[self buildFetcherFromStatement:sql] fetchRecords];
}

+(NSArray*)findAllInTimeRangeFrom:(NSTimeInterval)fromSec1970 to:(NSTimeInterval)toSec1970{
    return [[self buildFetcherWithFrom:fromSec1970 to:toSec1970] fetchRecords];
}

+(NSUInteger)countInTimeRangeFrom:(NSTimeInterval)fromSec1970 to:(NSTimeInterval)toSec1970{
    return [[self buildFetcherWithFrom:fromSec1970 to:toSec1970] count];
}

+(NSArray*)findLast:(NSUInteger)count offset:(NSUInteger)offset{
    ARLazyFetcher *f = [self lazyFetcher];
    NSArray *records = [[[[f orderBy:@"createdAt" ascending:NO] limit:count] offset:offset] fetchRecords];

    // return as the normal order to outside
    return [records sortBy:@"id"];
}

+(instancetype)findByPId:(NSNumber*)pID{
    ARLazyFetcher *f = [self lazyFetcher];
    return [[f whereField:@"id" equalToValue:pID] jsFetchOne];
}

#pragma mark delete

+(void)deleteAllWhereField:(NSString*)field notIn:(NSSet*)valueList otherCondition:(NSString*)other{
    other = other ? [NSString stringWithFormat:@" and %@ ", other] : @"";
    
    NSString *state = [NSString stringWithFormat:@"delete from %@ where %@ not in ( %@ ) %@",
                       self, field, [[valueList allObjects] join:@","], other];
    [self executeStatement:state];
}

+(void)deleteAllWhereField:(NSString*)field in:(NSSet*)valueList otherCondition:(NSString*)other{
    other = other ? [NSString stringWithFormat:@" and %@ ", other] : @"";

    NSString *state = [NSString stringWithFormat:@"delete from %@ where %@ in (%@) %@",
                       self, field, [[valueList allObjects] join:@","], other];
    [self executeStatement:state];
}

#pragma mark batch ops

+(void)batchOperationWithEntities:(NSArray*)entityList
                           action:(void (^)(ActiveRecordEntity *entity))action
                         complete:(void (^)(void))block {
    [Executors dispatchAsync:DISPATCH_QUEUE_PRIORITY_HIGH task:^{
        if (entityList.count > 0) {
            [ActiveRecord transaction:^{
                for(ActiveRecordEntity *entity in entityList){
                    action(entity);
                }
            }];
        }
        
        if (block) block();
    }];
}

+(void)batchSaveToDB:(NSArray*)entityList complete:(void (^)(void))block {
    [self batchOperationWithEntities:entityList
                              action:^(ActiveRecordEntity *entity) {
                                  [entity save];
                              }
                            complete:block];
}

+(void)batchDeleteInDB:(NSArray*)entityList complete:(void (^)(void))block{
    [self batchOperationWithEntities:entityList
                              action:^(ActiveRecordEntity *entity) {
                                  [entity dropRecord];
                              }
                            complete:block];
}

#pragma mark NSDictionary to entity

-(void)fillData:(NSDictionary*)data keyPath:(NSString*)keyPath defaultValue:(id)dValue field:(NSString*)field{
    id value = [data valueForKeyPath:keyPath];
    if (!value || [value class] == NSNull.class) {
        value = dValue;
    }
    
    [self setValue:value forKey:field];
}

#pragma mark extraInfo

-(void)addExtra:(id)value forKey:(NSString*)key{
    if (!value) {
        return;
    }
    
    if (!self.extraInfo) {
        self.extraInfo = [NSMutableDictionary dictionary];
    }
    // when is load from DB by iActiveRecord, extraInfo is NSDictionary, so we need make it mutable
    else if (self.extraInfo.class != NSMutableDictionary.class){
        self.extraInfo = [NSMutableDictionary dictionaryWithDictionary:self.extraInfo];
    }
    
    self.extraInfo[key] = value;
    [self setValue:self.extraInfo forKey:@"extraInfo"];// trigger iActiveRecord's change set, let it update this field
}

@end
