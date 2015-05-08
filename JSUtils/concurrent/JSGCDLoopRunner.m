//
//  JSGCDLoopRunner.m
//  JSUtils
//
//  Created by jackysong on 14-9-30.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "JSGCDLoopRunner.h"

#pragma mark - JSGCDTimer

@interface JSGCDTimer : NSObject

@property (nonatomic, copy) dispatch_block_t block;
@property (nonatomic, assign) dispatch_source_t source;

- (instancetype)initWithTimeInterval:(NSTimeInterval)seconds worker:(dispatch_queue_t)worker
                                task:(void (^)(void))block;

@end

@implementation JSGCDTimer

- (instancetype)initWithTimeInterval:(NSTimeInterval)seconds worker:(dispatch_queue_t)worker
                                task:(void (^)(void))block{
    self = [super init];
    if (self) {
        self.block = block;
        self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                              0, 0,
                                              worker);
        uint64_t interval = (uint64_t)(seconds * NSEC_PER_SEC);
        dispatch_source_set_timer(self.source,
                                  dispatch_time(DISPATCH_TIME_NOW, interval),
                                  interval, 0);
        dispatch_source_set_event_handler(self.source, block);
        dispatch_resume(self.source);
    }
    return self;
}

- (void)invalidate {
    if (self.source) {
        dispatch_source_cancel(self.source);
        dispatch_release(self.source);
        self.source = nil;
    }
    JS_releaseSafely(_block);
}

- (void)dealloc {
    [self invalidate];
    [super dealloc];
}

@end

#pragma mark - JSGCDLoopRunner

@implementation JSGCDLoopRunner{
    dispatch_queue_t timerWorker;
    NSMutableDictionary *timerTable; // @{name -> JSGCDTimer}
}

- (instancetype)init{
    self = [super init];
    if (self) {
        timerWorker = dispatch_queue_create("__JSGCDLoopRunner_timerWorker__", DISPATCH_QUEUE_SERIAL);
        timerTable = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc{
    JS_releaseSafely(timerTable);
    dispatch_release(timerWorker);
    [super dealloc];
}

-(void)addLoopingWithName:(NSString*)name interval:(NSTimeInterval)seconds task:(void (^)(void))block{
    [self removeLooping:name];
    timerTable[name] = [[JSGCDTimer alloc] initWithTimeInterval:seconds worker:timerWorker task:block];
}

-(void)removeLooping:(NSString*)name{
    JSGCDTimer *timer = timerTable[name];
    if (!timer) return;
    
    [timerTable removeObjectForKey:name];
    [timer release];
}

@end
