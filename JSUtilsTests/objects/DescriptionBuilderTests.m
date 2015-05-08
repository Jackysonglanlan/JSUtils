//
//  DescriptionBuilderTests.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-23.
//  Copyright (c) 2012年 Cybercom. All rights reserved.
//

#import "AbstractTests.h"
#import "DescriptionBuilder.h"

@interface DescriptionBuilderTests : AbstractTests @end


@implementation DescriptionBuilderTests

// All code under test must be linked into the Unit Test bundle
- (void)testReflectDescription{
  
  NSString *log = [DescriptionBuilder reflectDescription:[[[NSArray alloc]init] autorelease]];

  assertThat(log, containsString(@"__NSArrayI"));
}

@end
