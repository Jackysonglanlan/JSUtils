//
//  TestProxy.h
//  Labrary
//
//  Created by jacky.song on 13-3-20.
//  Copyright (c) 2013 symbio.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AOPContext : NSProxy{
    NSMutableDictionary *beforeAdviceTable;
    NSMutableDictionary *afterAdviceTable;
    NSMutableDictionary *aroundAdviceTable;
    id delegate;
}

+(id)aopEnhance:(id)object;

-(id)initWithObject:(id)object;

// Return NO to intecept the method invocation
// arguments is nil if no argument
-(void)addBeforeAdvice:(BOOL (^)(SEL selector, NSArray *arguments))advice
                aspect:(NSString*)methodNameRegex;

// returnValue is nil if it's void
-(void)addAfterAdvice:(void (^)(SEL selector, id returnValue))advice
               aspect:(NSString*)methodNameRegex;

// You need do [invocation invoke] manually to call the method in around advice
// arguments is nil if no argument
-(void)addAroundAdvice:(void (^)(NSInvocation* invocation, NSArray *arguments))advice
                aspect:(NSString*)methodNameRegex;

// return nil if it's void
// WARNing: call it *after* you call [invocation invoke]
-(id)getReturnValue:(NSInvocation*)invocation;

// return nil if no argument
-(NSArray*)getArguments:(NSInvocation*)invocation;

-(id)boxPrimitiveValue:(NSString*)arguType argReader:(void (^)(void *arguPointer))block;

@end
