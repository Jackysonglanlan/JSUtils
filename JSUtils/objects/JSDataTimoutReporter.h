//
//  ICEPkgResender.h
//  CMGE-Core
//
//  Created by jackysong on 14-12-4.
//  Copyright (c) 2014年 cmge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSDataTimoutReporter : NSObject

// default is 1s
@property(nonatomic,assign) NSTimeInterval timeoutScanInterval;

// The dataDidTimeout block will be called if the interval exceeds this value.
// Default is 30s
@property(nonatomic,assign) NSTimeInterval timeoutAfterMarkInSec;

// The dataDidTimeout block will be called up to this value specified times for the same data,
// after that, the data will be deleted.
// Default is 3
@property(nonatomic,assign) NSUInteger maxTimeoutReportCount;

@property(nonatomic,copy) void (^dataDidTimeout)(NSString *dataId, id data);

- (void)markData:(id)data withId:(NSString*)dataId;

- (void)unmarkDataWithId:(NSString*)dataId;

@end
