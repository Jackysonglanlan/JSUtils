//
//  JSCompositePattern.h
//  JSUtils
//
//  Created by Song Lanlan on 8/3/15.
//  Copyright (c) 2015 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSCompositePattern;
@protocol JSComponent <NSObject>

/**
 * The higher value, the lower priority it is.
 */
-(NSInteger)priority;

-(void)setAssembler:(id)assembler;

-(void)setCompositePattern:(JSCompositePattern*)pattern;

@end

@interface JSCompositePattern : NSObject

- (id)initWithAssembler:(id)assembler;

/**
 * return the registered component
 */
-(id<JSComponent>)registerComponent:(Class)componentClass;

-(id<JSComponent>)getComponentByPriority:(NSInteger)priority;

/**
 * This method will iterate all the component based on their priority (desc order, lower value will be iterate first)
 */
-(void)doWithAllComponents:(void (^)(id<JSComponent> component))block;

@end
