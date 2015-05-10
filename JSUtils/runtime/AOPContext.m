//
//  TestProxy.m
//  Labrary
//
//  Created by jacky.song on 13-3-20.
//  Copyright (c) 2013 symbio.com. All rights reserved.
//

#import "AOPContext.h"
#import "ObjCTypeChecker.h"

@implementation AOPContext

+(id)aopEnhance:(id)object{
    return [[[AOPContext alloc] initWithObject:object] autorelease];
}

- (id)initWithObject:(id)object{
    beforeAdviceTable = [[NSMutableDictionary alloc] initWithCapacity:5];
    afterAdviceTable = [[NSMutableDictionary alloc] initWithCapacity:5];
    aroundAdviceTable = [[NSMutableDictionary alloc] initWithCapacity:5];
    delegate = object;
    return self;
}

- (void)dealloc{
    JS_releaseSafely(beforeAdviceTable);
    JS_releaseSafely(afterAdviceTable);
    JS_releaseSafely(aroundAdviceTable);
    [super dealloc];
}

#pragma mark public

-(void)addBeforeAdvice:(BOOL (^)(SEL selector, NSArray *arguments))advice
                aspect:(NSString*)methodNameRegex{
    beforeAdviceTable[methodNameRegex] = [advice copy];
}

-(void)addAfterAdvice:(void (^)(SEL selector, id returnValue))advice aspect:(NSString*)methodNameRegex{
    afterAdviceTable[methodNameRegex] = [advice copy];
}

-(void)addAroundAdvice:(void (^)(NSInvocation* invocation, NSArray *arguments))advice
                aspect:(NSString*)methodNameRegex{
    aroundAdviceTable[methodNameRegex] = [advice copy];
}

-(NSArray*)getArguments:(NSInvocation*)invocation{
    // get arguments if it has
    NSUInteger num = invocation.methodSignature.numberOfArguments;
    
    // there are always 2 args at least, hidden arguments: self and _cmd
    // so num == 2 means no args
    if (num == 2) return nil;
    
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:num-2];
    for (int i=2; i<num; i++) {
        NSString *arguType = [NSString stringWithCString:[invocation.methodSignature getArgumentTypeAtIndex:i]
                                                encoding:NSUTF8StringEncoding];
        arguments[i-2] = [self boxPrimitiveValue:arguType argReader:^(void *argPointer) {
            [invocation getArgument:argPointer atIndex:i];
        }];
    }
    return arguments;
}

-(id)getReturnValue:(NSInvocation*)invocation{
    NSString *retType = [NSString stringWithCString:[invocation.methodSignature methodReturnType]
                                           encoding:NSUTF8StringEncoding];
    return [self boxPrimitiveValue:retType argReader:^(void *argPointer) {
        [invocation getReturnValue:argPointer];
    }];
}

-(id)boxPrimitiveValue:(NSString*)arguType argReader:(void (^)(void *argPointer))block{
//    [arguType log];
    id objArg = nil;
    
    arguType = [ObjCTypeChecker idOfType:arguType];
    
    // short int long long-long NSInteger
    if ([arguType isMatchedByRegex:@"^[iIlsL]$"]) {
        long long argu;
        block(&argu);
        objArg = @(argu);
    }
    // BOOL
    else if ([arguType isEqualToString:@"b"]){
        BOOL argu;
        block(&argu);
        objArg = @(argu);
    }
    // float, double
    else if ([arguType isMatchedByRegex:@"^[fd]$"]){
        float argu = 0.0;
        block(&argu);
        objArg = @(argu);
    }
    // CGPoint
    else if ([arguType isEqualToString:@"CGPoint"]){
        CGPoint argu;
        block(&argu);
        objArg = pointObject(argu);
    }
    // CGSize
    else if ([arguType isEqualToString:@"CGSize"]){
        CGSize argu;
        block(&argu);
        objArg = sizeObject(argu);
    }
    // CGRect
    else if ([arguType isEqualToString:@"CGRect"]){
        CGRect argu;
        block(&argu);
        objArg = rectObject(argu);
    }
    // NSRange
    else if ([arguType isEqualToString:@"range"]){
        NSRange argu;
        block(&argu);
        objArg = rangeObject(argu);
    }
    // void
    else if ([arguType isEqualToString:@"v"]){
        // nothing
    }
    // NSObject
    else if ([arguType isEqualToString:@"object"]){
        block(&objArg);
    }
    else{
        // Unknown
        JS_Stub_Throw(@"AOPContext Fatal Error", @"Unknown iOS type: %@", arguType);
    }
    return objArg;
}

#pragma mark disguise

-(BOOL)isKindOfClass:(Class)aClass{
    return [delegate isKindOfClass:aClass];
}

-(BOOL)conformsToProtocol:(Protocol *)aProtocol{
    return [delegate conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [delegate respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    return [delegate methodSignatureForSelector:sel];
}

#pragma mark intecept

- (void)forwardInvocation:(NSInvocation *)invocation{
    invocation.target = delegate;
    SEL selector = invocation.selector;
    
    //////// before advice
    BOOL allowProcess = YES; // in case there's only "after advice" exists
    BOOL (^beforeAdvice)(SEL selector, NSArray *arguments) =
        [self findAdviceForSelector:selector table:beforeAdviceTable];
    
    if (beforeAdvice) {
        allowProcess = beforeAdvice(selector,[self getArguments:invocation]);
    }
    
    // not allowed, return
    if (!allowProcess) return;

    //////// around advice

    void (^aroundAdvice)(NSInvocation* invocation, NSArray *arguments) =
        [self findAdviceForSelector:selector table:aroundAdviceTable];
    
    // has around
    if (aroundAdvice) {
        // pass invocation to it
        aroundAdvice(invocation,[self getArguments:invocation]);
    }
    // no around
    else{
        // call method
        [invocation invoke];
    }

    //////// after advice
    
    void (^afterAdvice)(SEL selector, id returnValue) =
        [self findAdviceForSelector:selector table:afterAdviceTable];
    
    if (afterAdvice) {
        afterAdvice(selector, [self getReturnValue:invocation]);
    }
}

-(id)findAdviceForSelector:(SEL)selector table:(NSDictionary*)table{
    for (NSString *aspect in [table allKeys]) {
        if ([NSStringFromSelector(selector) isMatchedByRegex:aspect]) {
            return table[aspect];
        }
    }
    return nil;
}

@end
