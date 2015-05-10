//
//  FMDBHelper.h
//  CMGESocialSDK
//
//  Created by jackysong on 14-4-11.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface FMDBHelper : NSObject

-(id)initWithDBAtPath:(NSString*)path;

/**
 *  Helper method to process rowset.
 *
 *  @param stat   SQL statement
 *  @param block  Closure
 */
-(void)doWithStatement:(NSString*)stat process:(void (^)(FMResultSet *rs))block;

/**
 *  Helper method to get rowset data.
 *
 *  @param stat   SQL statement
 *  @param fields The field names from which you want to get value, nil means all the fields
 *  @param block  Closure
 */
-(void)doWithStatement:(NSString*)stat fields:(NSArray*)fields processRowData:(void (^)(NSDictionary *rawData))block;

@end
