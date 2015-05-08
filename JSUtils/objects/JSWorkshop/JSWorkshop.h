//
//  JSWorkshop.h
//  JSUtils
//
//  Created by jackysong on 14-12-3.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSPipeLine.h"

@interface JSWorkshop : NSObject

- (void)addPipeLine:(JSPipeLine*)line forId:(NSString*)identifier;

- (void)removePipeLineWithId:(NSString*)identifier ;

- (JSPipeLine*)getPipeLineWithId:(NSString*)identifier;

- (NSArray*)getAllPipeLineIdList;

- (void)runPipeLineWithId:(NSString*)identifier andInitData:(id)data completion:(void(^)(id finalProduct))completion;

@end
