//
//  ActiveRecordDemoTests.m
//  ActiveRecordDemoTests
//
//  Created by Song Lanlan on 21/6/14.
//  Copyright (c) 2014 Song Lanlan. All rights reserved.
//

#import "AbstractTests.h"

#import "ActiveRecordEntity.h"

#pragma mark - entity

@interface TestEntity : ActiveRecordEntity

@property(nonatomic,retain) NSNumber *type;

@property(nonatomic,retain) NSNumber *fromUUID;
@property(nonatomic,retain) NSNumber *toUUID;
@property(nonatomic,retain) NSNumber *groupId;
@property(nonatomic,retain) NSNumber *msgId;
@property(nonatomic,retain) NSString *content;

@end

@implementation TestEntity

-(void)dealloc{
    self.type = nil;
    self.fromUUID = nil;
    self.toUUID = nil;
    self.groupId = nil;
    self.msgId = nil;
    self.content = nil;
    self.extraInfo = nil;
    
    [super dealloc];
}

@end

#pragma mark - test

@interface ActiveRecordTests : AbstractTests

@end

@implementation ActiveRecordTests

- (void)testActiveRecord{
    [ActiveRecord transaction:^{
        for(int i=0;i<1000;i++){
            TestEntity *foo = [TestEntity newRecord];
            foo.fromUUID = @(i);
            foo.toUUID = @(i);
            foo.groupId = @(i);
            foo.type = @(i);
            foo.msgId = @(i);
            foo.content = @"aaa";
            
            [foo addExtra:@(i) forKey:@"key"];
            
            [foo save];
            
            NSNumber *pid = foo.id;
            
            [foo release];

            foo = [TestEntity findByPId:pid];
            [foo addExtra:@"中文" forKey:@"str"];
            [foo setValue:@(i) forKey:@"content"];
            [foo save];
        }
    }];
    
//    [self beginAsyncOperationWithTimeout:60];
}

- (void) testActiveRecordQuery {
    NSArray *list = [[[TestEntity lazyFetcher] whereField:@"id" between:@1 and:@10] fetchRecords];
    NSLog(@"%@", list);
}

@end
