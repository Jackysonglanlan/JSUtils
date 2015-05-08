//
//  JSCompositePatternTests.m
//  JSUtils
//
//  Created by admin on 15/5/4.
//  Copyright (c) 2015年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"

#import "JSCompositePattern.h"

@interface Com1 : NSObject<JSComponent>

-(void)aaa;

@end

@implementation Com1

-(void)aaa{
    DLog(@"aaa");
}

- (NSInteger)priority {
    return 11;
}

-(void)setAssembler:(id)assembler{
    
}

-(void)setCompositePattern:(JSCompositePattern*)pattern{
    
}

@end

@interface Com2 : NSObject<JSComponent>

-(void)bbb:(int)param param2:(NSString*)p2;

@end

@implementation Com2

-(void)bbb:(int)param param2:(NSString*)p2{
    DLog(@"bbb-%d-%@",param,p2);
}

- (NSInteger)priority {
    return 2;
}

-(void)setAssembler:(id)assembler{
    
}

-(void)setCompositePattern:(JSCompositePattern*)pattern{
    
}

@end

@interface Com3 : NSObject<JSComponent>

-(void)aaa;

@end

@implementation Com3

-(void)aaa{
    DLog(@"aaa3");
}

- (NSInteger)priority {
    return 3;
}

-(void)setAssembler:(id)assembler{
    
}

-(void)setCompositePattern:(JSCompositePattern*)pattern{
    
}

@end



@interface JSCompositePatternTests : AbstractTests
@end

@implementation JSCompositePatternTests{
    JSCompositePattern *pattern;
}

- (void)before {
    pattern = [[JSCompositePattern alloc] initWithAssembler:self];
    [pattern registerComponent:Com1.class];
    [pattern registerComponent:Com2.class];
    [pattern registerComponent:Com3.class];
}

- (void)testExample{
    [pattern aaa];
    [pattern bbb:333 param2:@"elegant"];
}

@end
