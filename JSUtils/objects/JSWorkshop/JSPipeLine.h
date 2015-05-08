//
//  JSPipeLine.h
//  JSUtils
//
//  Created by jackysong on 14-12-3.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSPipeLineUnit.h"

@interface JSPipeLineContext : NSObject

/**
 * Call the next unit to continue process.
 *
 * @param dataToNextUnit data will pass to the next unit to process
 */
- (void)next:(id)dataToNextUnit;

/**
 * Go to the specified unit to continue process.
 *
 * @param index the target process step, 0-based
 * @param data data will pass to the next unit to process
 */
- (void)gotoStep:(NSUInteger)index withData:(id)data;

/**
 * Call off the entire PipeLine process, then callback pipeLineDidFinishWorking block.
 *
 * @param outData data will pass to the pipeLineDidFinishWorking block
 */
- (void)stop:(id)outData;

@end

@interface JSPipeLine : NSObject

@property(nonatomic,copy) void(^pipeLineDidFinishWorking)(id outcome);

/**
 * Install a block unit to PipeLine.
 *
 * @param block process logic
 * @param index the step the block unit will be installed, 0-based
 */
-(void)installBlockUnit:(void (^)(id income, JSPipeLineContext *context))block toStepIndex:(NSUInteger)index;

- (void)installUnit:(id<JSPipeLineUnit>)unit toStepIndex:(NSUInteger)index;

- (void)uninstallUnitAtStepIndex:(NSUInteger)index;

-(id<JSPipeLineUnit>)unitAtIndex:(NSUInteger)index;

- (NSArray*)installedUnits;

- (void)runWithInitData:(id)data;

@end
