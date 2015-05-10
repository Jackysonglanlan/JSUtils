//
//  ObjCTypeChecker.m
//  Labrary
//
//  Created by jacky.song on 13-3-27.
//  Copyright (c) 2013 symbio.com. All rights reserved.
//

#import "ObjCTypeChecker.h"

@interface Tmp : NSObject

///////// type check method /////////

-(void)c:(char)c s:(short)s i:(int)i l:(long)l L:(long long)ll b:(BOOL)b f:(float)f d:(double)d
       I:(NSInteger)nsi
    CGPoint:(CGPoint)p CGSize:(CGSize)size CGRect:(CGRect)rect range:(NSRange)range object:(id)obj;
@end

@implementation Tmp

-(void)c:(char)c s:(short)s i:(int)i l:(long)l L:(long long)ll b:(BOOL)b f:(float)f d:(double)d
       I:(NSInteger)nsi
    CGPoint:(CGPoint)p CGSize:(CGSize)size CGRect:(CGRect)rect range:(NSRange)range object:(id)obj{  
}

@end


@implementation ObjCTypeChecker

// [real type -> typeId]
static NSMutableDictionary *typeTable;

+(void)initialize{
    if ([self class] == ObjCTypeChecker.class) {
        typeTable = [[NSMutableDictionary alloc] initWithCapacity:15];
        
        SEL selector = @selector(c:s:i:l:L:b:f:d:I:CGPoint:CGSize:CGRect:range:object:);
        Tmp *tmp = [Tmp new];
        NSMethodSignature *sig = [tmp methodSignatureForSelector:selector];
        [tmp release];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        // why invocation.selector = nil?
        
        NSUInteger argNum = invocation.methodSignature.numberOfArguments;
        
        NSArray *types = [NSStringFromSelector(selector) componentsSeparatedByString:@":"];
        
        for (int i=2; i<argNum; i++) {
            NSString *arguType = [NSString stringWithCString:[invocation.methodSignature getArgumentTypeAtIndex:i]
                                                    encoding:NSUTF8StringEncoding];
            typeTable[arguType] = types[i-2];
        }
        
        // add void type for return type
        typeTable[[NSString stringWithCString:[invocation.methodSignature methodReturnType]
                                     encoding:NSUTF8StringEncoding]] = @"v";
    }
//    [typeTable log];
}

+(NSArray*)allTypeIds{
    return [[[typeTable allValues] copy] autorelease];
}

+(BOOL)isTypeId:(NSString*)tId matches:(NSString*)type{
    return [[self idOfType:type] isEqualToString:tId];
}

+(NSString*)idOfType:(NSString*)type{
    return typeTable[type];
}

@end
