//
//  JSCompositePattern.m
//  JSUtils
//
//  Created by Song Lanlan on 8/3/15.
//  Copyright (c) 2015 Jacky.Song. All rights reserved.
//

#import "JSCompositePattern.h"

@implementation JSCompositePattern{
    // @{priority -> JSComponent}
    NSMutableDictionary *components;
    NSMutableArray *priorityArray;
    id assembler;
}

- (id)initWithAssembler:(id)assem{
    self = [super init];
    if (self) {
        components = [NSMutableDictionary new];
        priorityArray = [NSMutableArray new];
        assembler = assem;
    }
    return self;
}

-(void)dealloc{
    JS_releaseSafely(components);
    JS_releaseSafely(priorityArray);
    [super dealloc];
}

#pragma mark method dispatch

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    __block NSMethodSignature *sig = [super methodSignatureForSelector:sel];
    
    if (!sig) {
        [self doWithAllComponents:^(id<JSComponent> component) {
            NSMethodSignature *tmpSig = [(NSObject*)component methodSignatureForSelector:sel];
            if (tmpSig) {
                sig = tmpSig;
                return;
            }
        }];
    }
    
    return sig;
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    BOOL base = [super respondsToSelector:aSelector];
    if (base) {
        return base;
    }
    
    __block BOOL result = NO;
    [self doWithAllComponents:^(id<JSComponent> component) {
        if ([component respondsToSelector:aSelector]) {
            result = YES;
            return;
        }
    }];
    
    return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    [self doWithAllComponents:^(id<JSComponent> component) {
        if ([component respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:component];
        }
    }];
}

#pragma mark private

- (void)sortPriorityValueLowToHigh {
    [priorityArray sortUsingSelector:@selector(compare:)];
}

#pragma mark public

-(id<JSComponent>)registerComponent:(Class)componentClass{
    id<JSComponent> component = [[componentClass new] autorelease];
    [component setAssembler:assembler];
    [component setCompositePattern:self];
    
    NSNumber *priority = @([component priority]);
    
    components[priority] = component;
    [priorityArray addObject:priority];
    
    [self sortPriorityValueLowToHigh];
    
    return component;
}

-(id<JSComponent>)getComponentByPriority:(NSInteger)priority{
    return components[@(priority)];
}

-(void)doWithAllComponents:(void (^)(id<JSComponent> component))block{
    for (NSNumber *priority in priorityArray) {
        block(components[priority]);
    }
}

@end
