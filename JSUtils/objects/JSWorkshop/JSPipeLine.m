//
//  JSPipeLine.m
//  JSUtils
//
//  Created by jackysong on 14-12-3.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "JSPipeLine.h"

#import "JSPipeLineUnit.h"

#pragma mark -

@interface JSPipeLineContext ()

- (instancetype)initWithPipeLine:(JSPipeLine*)line;

@property(nonatomic,copy) void(^pipeLineDidFinishWorking)(id outcome);

@end

#pragma mark -

@interface JSPipeLineBlockUnit : NSObject<JSPipeLineUnit>
@property(nonatomic,copy) void (^block)(id income, JSPipeLineContext *context);
@end

@implementation JSPipeLineBlockUnit

- (void)dealloc{
    JS_releaseSafely(_block);
    [super dealloc];
}

-(void)process:(id)income context:(JSPipeLineContext*)context{
    self.block(income, context);
}

@end

#pragma mark -

@implementation JSPipeLine{
    NSMutableArray *line;
    JSPipeLineContext *context;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        line = [[NSMutableArray alloc] initWithCapacity:5]; // adjust
    }
    return self;
}

- (void)dealloc{
    JS_releaseSafely(line);
    JS_releaseSafely(_pipeLineDidFinishWorking);
    [super dealloc];
}

#pragma mark private

- (void)runUnitAtStep:(NSUInteger)index withData:(id)data {
    id<JSPipeLineUnit> unit = line[index];
    [unit process:data context:context];
}

- (void)releaseContext {
    JS_releaseSafely(context);
}

#pragma mark public

-(void)installBlockUnit:(void (^)(id income, JSPipeLineContext *context))block toStepIndex:(NSUInteger)index{
    JSPipeLineBlockUnit *unit = [JSPipeLineBlockUnit new];
    unit.block = block;
    [self installUnit:unit toStepIndex:index];
    [unit release];
}

- (void)installUnit:(id<JSPipeLineUnit>)unit toStepIndex:(NSUInteger)index {
    [line insertObject:unit atIndex:index];
}

//- (void)moveUnitAtStepIndex:(NSUInteger)from toStepIndex:(NSUInteger)to{}

- (void)uninstallUnitAtStepIndex:(NSUInteger)index {
    [line removeObjectAtIndex:index];
}

-(id<JSPipeLineUnit>)unitAtIndex:(NSUInteger)index{
    return [line objectAtIndex:index];
}

- (NSArray*)installedUnits {
    return [[line copy] autorelease];
}

- (void)runWithInitData:(id)data {
    NSAssert(line.count > 0, @"Can't run pipeLine because it has NO working unit !");
    
    BOOL isRunning = (context != nil);
    if (isRunning) return;
    
    context = [[JSPipeLineContext alloc] initWithPipeLine:self];
    
    __block JSPipeLine *weakSelf = self;
    [context setPipeLineDidFinishWorking:^(id outcome) {
        if (weakSelf.pipeLineDidFinishWorking)  weakSelf.pipeLineDidFinishWorking(outcome);
        [weakSelf releaseContext];
    }];

    [context next:data];
}

@end

#pragma mark -

@implementation JSPipeLineContext{
    JSPipeLine *pipeLine;
    
    NSUInteger currStep;
    NSUInteger lastStep;
}

- (instancetype)initWithPipeLine:(JSPipeLine*)line{
    self = [super init];
    if (self) {
        pipeLine = line; // weak refer
        
        currStep = 0;
        lastStep = [line installedUnits].count - 1;
    }
    return self;
}

- (void)dealloc{
    JS_releaseSafely(_pipeLineDidFinishWorking);
    [super dealloc];
}

- (void)next:(id)dataToNextUnit {
    // no more
    if (currStep > lastStep) {
        [self stop:dataToNextUnit];
        return;
    }

    NSUInteger targetStep = currStep;
    
    currStep++; // must add in advance, or the next will be infinite recursion.

    [self gotoStep:targetStep withData:dataToNextUnit];
}

- (void)gotoStep:(NSUInteger)index withData:(id)data {
    [pipeLine runUnitAtStep:index withData:data];
    currStep = index;
}

- (void)stop:(id)outData {
    if (self.pipeLineDidFinishWorking) self.pipeLineDidFinishWorking(outData);
}

@end
