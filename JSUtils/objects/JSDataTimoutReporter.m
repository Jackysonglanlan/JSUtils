//
//  ICEPkgResender.m
//  CMGE-Core
//
//  Created by jackysong on 14-12-4.
//  Copyright (c) 2014年 cmge. All rights reserved.
//

#import "JSDataTimoutReporter.h"

#pragma mark -

@interface JSDataTimoutReporterInnerObj : NSObject
@property(nonatomic, assign) NSTimeInterval sendTime;
@property(nonatomic, retain) id data;
@property(nonatomic, assign) NSUInteger reportCount;
@end

@implementation JSDataTimoutReporterInnerObj
- (void)dealloc{
    JS_releaseSafely(_data);
    [super dealloc];
}
@end

#pragma mark -

@implementation JSDataTimoutReporter{
    NSMutableDictionary *dataTable; // @{dataId(NSString) -> data(JSDataTimoutReporterInnerObj)}
    
    dispatch_source_t timer;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        dataTable = [NSMutableDictionary new];
        
        [self setDefaultValues];
        [self getTimerReady];
    }
    return self;
}

- (void)setDefaultValues {
    self.timeoutScanInterval = 1;
    self.timeoutAfterMarkInSec = 30;
    self.maxTimeoutReportCount = 3;
}

- (void)getTimerReady {
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,
                                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    
    dispatch_source_set_timer(timer,  DISPATCH_TIME_NOW, self.timeoutScanInterval * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(timer, ^{
        [self doInTimer];
    });
    
    dispatch_source_set_cancel_handler(timer, ^{
//        NSLog(@"cancel");
        dispatch_release(timer);
    });
    
    dispatch_resume(timer);
}

- (void)dealloc{
    JS_releaseSafely(dataTable);
    dispatch_source_cancel(timer);
    
    JS_releaseSafely(_dataDidTimeout);
    [super dealloc];
}

- (void)timingDataWithId:(NSString*)dataId{
    JSDataTimoutReporterInnerObj *obj = dataTable[dataId];
    obj.sendTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)recordData:(id)data withId:(NSString*)dataId{
    if (dataTable[dataId]) return;

    JSDataTimoutReporterInnerObj *obj = [JSDataTimoutReporterInnerObj new];
    obj.data = data;
    dataTable[dataId] = obj;
    [obj release];
    
    [self timingDataWithId:dataId];
}

- (void)deleteRecordedDataWithId:(NSString*)dataId{
    [dataTable removeObjectForKey:dataId];
}

- (void)doInTimer {
    [self scanTimeoutData:^(NSString *dataId) {
        JSDataTimoutReporterInnerObj *obj = dataTable[dataId];
        [self reportTimeoutData:obj.data withId:dataId];
        [self timingDataWithId:dataId];// retiming pkg to next scan
    }];
}

-(void)scanTimeoutData:(void (^)(NSString *dataId))foundTimeoutDataBlock{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    for (NSString *dataId in [dataTable allKeys]) {
        JSDataTimoutReporterInnerObj *obj = dataTable[dataId];
        NSTimeInterval sendTime = obj.sendTime;
        
        BOOL isExpired = ((now - sendTime) > self.timeoutAfterMarkInSec);
        if (!isExpired) continue;
        
        DLog(@"Found timeout data with Id:%@", dataId);

        foundTimeoutDataBlock(dataId);
    }
}

- (void)reportTimeoutData:(id)data withId:(NSString*)dataId{
    if (self.dataDidTimeout) self.dataDidTimeout(dataId, data);
    [self addReportCountWithId:dataId];
    [self deleteDataIfExceedMaxReportCountWithId:dataId];
}

- (void)addReportCountWithId:(NSString*)dataId{
    JSDataTimoutReporterInnerObj *obj = dataTable[dataId];
    obj.reportCount += 1;
}

- (void)deleteDataIfExceedMaxReportCountWithId:(NSString*)dataId{
    JSDataTimoutReporterInnerObj *obj = dataTable[dataId];
    if (obj.reportCount < self.maxTimeoutReportCount) return;
    
    [self unmarkDataWithId:dataId];
}

#pragma mark public

- (void)markData:(id)data withId:(NSString*)dataId{
    [self recordData:data withId:dataId];
}

- (void)unmarkDataWithId:(NSString*)dataId{
    [self deleteRecordedDataWithId:dataId];
}

@end
