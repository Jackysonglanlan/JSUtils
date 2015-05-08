//
//  MAObjCRuntimeTests.m
//  JSUtils
//
//  Created by admin on 15/1/12.
//  Copyright (c) 2015年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"

#import "MARTNSObject.h"
#import "RTProtocol.h"
#import "RTIvar.h"
#import "RTProperty.h"
#import "RTMethod.h"
#import "RTUnregisteredClass.h"

@interface MAObjCRuntimeTests : AbstractTests

@end

@implementation MAObjCRuntimeTests

- (void)testQuerying{
    // get all subclasses of a class
    NSArray *subclasses = [NSArray rt_subclasses];
    NSLog(@"%@", subclasses);

    // check out the methods on NSString
    NSArray *methods = [NSString rt_methods];
    NSLog(@"%@", methods);
    
    // does it have any ivars?
    NSLog(@"%@", [NSString rt_ivars]);
    
    // how big is a constant string instance?
    NSLog(@"%ld", (long)[[@"foo" rt_class] rt_instanceSize]);
}

- (void)testSwizzleMethod {
    RTMethod *description = [NSObject rt_methodForSelector: @selector(description)];
    [description setImplementation: (IMP)NewDescription];
    assertThat([[NSObject new] description], is(@"HELLO WORLD!"));
}
// swizzle out -[NSObject description] (don't do this)
static NSString *NewDescription(id self, SEL _cmd){
    return @"HELLO WORLD!";
}


- (void)testAddClassOnTheFly {
    Class subclass = [NSObject rt_createSubclassNamed: @"MATestSubclass"];
    assertThatBool(![subclass isSubclassOfClass: [NSString class]], equalToBool(YES));
    [subclass rt_setSuperclass: [NSString class]];
    assertThatBool([subclass isSubclassOfClass: [NSString class]], equalToBool(YES));
    [subclass rt_destroyClass];
}

-(void)testMethodList{
    NSArray *methods = [NSObject rt_methods];
    SEL sel = @selector(description);
    NSUInteger index = [methods indexOfObjectPassingTest: ^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [obj selector] == sel;
    }];
    assertThatInt(index, lessThan(@([methods count])));
    
    RTMethod *method = [methods objectAtIndex: index];
    assertThatBool([method implementation] == [NSObject instanceMethodForSelector: sel], equalToBool(YES));
    assertThat([NSMethodSignature signatureWithObjCTypes: [[method signature] UTF8String]],
                equalTo([NSObject instanceMethodSignatureForSelector: sel]));
}

- (void)testMethodFetching {
    SEL sel = @selector(description);
    RTMethod *method = [NSObject rt_methodForSelector: sel];
    assertThatBool([method implementation] == [NSObject instanceMethodForSelector: sel], equalToBool(YES));
    assertThat([NSMethodSignature signatureWithObjCTypes: [[method signature] UTF8String]],
               equalTo([NSObject instanceMethodSignatureForSelector: sel]));
}

- (void)testMessageSending {
    id obj1 = [[[NSObject rt_class] rt_methodForSelector: @selector(alloc)] sendToTarget: [NSObject class]];
    id obj2;
    [[[NSObject rt_class] rt_methodForSelector: @selector(alloc)] returnValue: &obj2 sendToTarget: [NSObject class]];
    assertThat(obj1, notNilValue());
    assertThat(obj2, notNilValue());

    BOOL equal;
    [[NSObject rt_methodForSelector: @selector(isEqual:)] returnValue: &equal sendToTarget: obj1, RTARG(obj1)];
    assertThatBool(equal, equalToBool(YES));
    [[NSObject rt_methodForSelector: @selector(isEqual:)] returnValue: &equal sendToTarget: obj1, RTARG(obj2)];
    assertThatBool(equal, equalToBool(NO));
    [obj1 release];
    [obj2 release];
}

@end
