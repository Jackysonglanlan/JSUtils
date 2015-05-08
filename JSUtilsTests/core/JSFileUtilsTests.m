//
//  ZipTests.m
//  FastTest
//
//  Created by Song Lanlan on 13-9-27.
//  Copyright (c) 2013年 tiantian. All rights reserved.
//

#import "AbstractTests.h"
#import "JSFileUtils.h"

@interface JSFileUtilsTests : AbstractTests

@end

@implementation JSFileUtilsTests

-(void)testIterateFiles{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];

  [JSFileUtils iterateFileInDir:documentsDirectory doWithFile:^(NSString *filePath) {
    if (![filePath isMatchedByRegex:[NSString stringWithFormat:@"%@$",kRegex_FileExtension]]) {
      NSLog(@"%@",filePath);
    }
  }];
}

@end
