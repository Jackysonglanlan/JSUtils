//
//  BaseEntity.h
//  CMGESocialSDK
//
//  Created by jackysong on 14-3-11.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "ActiveRecord.h"

/**
 *  Super class of all the class who needs persistence to DB using iActiveRecord.
 *
 *  Warning: when you need to save an entity's property repeatedly to DB, you *MUST* use setValue:forKey: method
 *  to set its property, or it won't be saved.
 */
@interface ActiveRecordEntity : ActiveRecord

+(void)executeStatement:(NSString*)statement;

+(ARLazyFetcher*)buildFetcherFromStatement:(NSString*)state;

#pragma mark find and count

+(id)findOneWithStatement:(NSString*)statement;

+(NSArray*)findAllInList:(NSArray*)values fieldName:(NSString*)field;

+(NSArray*)findAllInTimeRangeFrom:(NSTimeInterval)fromSec1970 to:(NSTimeInterval)toSec1970;

+(NSUInteger)countInTimeRangeFrom:(NSTimeInterval)fromSec1970 to:(NSTimeInterval)toSec1970;

/**
 *  Query the last 'count' number of records.
 *
 *  @param count  the num of records you want to query
 *  @param offset the last record's index for the matched record, 0 based(means 0 is last one, 1 means last - 1)
 *
 *  @return the records
 */
+(NSArray*)findLastCreatedWithCount:(NSUInteger)count offset:(NSUInteger)offset;

/**
 * Similar as -findLastCreatedWithCount:offset:
 */
+(NSArray*)findLastUpdatedWithCount:(NSUInteger)count offset:(NSUInteger)offset;

+(instancetype)findByPId:(NSNumber*)pID;

#pragma mark delete

+(void)deleteAllWhereField:(NSString*)field notIn:(NSSet*)valueList otherCondition:(NSString*)other;

+(void)deleteAllWhereField:(NSString*)field in:(NSSet*)valueList otherCondition:(NSString*)other;

#pragma mark batch ops

+(void)batchOperationWithEntities:(NSArray*)entityList
                           action:(void (^)(ActiveRecordEntity *entity))action
                         complete:(void (^)(void))block;

+(void)batchSaveToDB:(NSArray*)list complete:(void (^)(void))block;

+(void)batchDeleteInDB:(NSArray*)entityList complete:(void (^)(void))block;

#pragma mark NSDictionary to entity

-(void)fillData:(NSDictionary*)data keyPath:(NSString*)key defaultValue:(id)dValue field:(NSString*)field;

#pragma mark extraInfo

// Armed with this property, we don't have to modify the table structure.
// iActiveRecord will save it as JSON String
@property(nonatomic,retain) NSMutableDictionary *extraInfo;

-(void)addExtra:(id)value forKey:(NSString*)key;

@end
