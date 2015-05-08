//
//  JSWorkshop.m
//  JSUtils
//
//  Created by jackysong on 14-12-3.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "JSWorkshop.h"

@implementation JSWorkshop{
    NSMutableDictionary *pipeLineMap; // @{line id -> JSPipeLine}
    dispatch_queue_t workers;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        pipeLineMap = [[NSMutableDictionary alloc] initWithCapacity:3]; // adjust
        workers = dispatch_queue_create("JSWorkshop_worker", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc{
    JS_releaseSafely(pipeLineMap);
    dispatch_release(workers);
    [super dealloc];
}

- (void)addPipeLine:(JSPipeLine*)line forId:(NSString*)identifier{
    pipeLineMap[identifier] = line;
}

- (void)removePipeLineWithId:(NSString*)identifier {
    [pipeLineMap removeObjectForKey:identifier];
}

- (JSPipeLine*)getPipeLineWithId:(NSString*)identifier {
    return pipeLineMap[identifier];
}

- (NSArray*)getAllPipeLineIdList {
    return [[[pipeLineMap allKeys] copy] autorelease];
}

- (void)runPipeLineWithId:(NSString*)identifier andInitData:(id)data completion:(void(^)(id finalProduct))completion{
    dispatch_async(workers, ^{
        JSPipeLine *line = [self getPipeLineWithId:identifier];
        [line setPipeLineDidFinishWorking:^(id outcome) {
            if (completion) completion(outcome);
        }];
        
        [line runWithInitData:data];
    });
}

@end
