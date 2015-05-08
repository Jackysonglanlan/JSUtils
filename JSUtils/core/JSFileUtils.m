//
//  JSFileUtils.m
//  FastTest
//
//  Created by Song Lanlan on 13-9-27.
//  Copyright (c) 2013年 tiantian. All rights reserved.
//

#import "JSFileUtils.h"

@implementation JSFileUtils

+(void)iterateFileInDir:(NSString*)dirPath doWithFile:(void (^)(NSString *filePath))block{
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSArray *files = [fileManager subpathsOfDirectoryAtPath:dirPath error:nil];
  if (files) {
    for (NSString *path in files) {
      block(path);
    }
  }
}

+(void)cleanDir:(NSString*)dirPath{
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:dirPath error:nil];
    [manager createDirectoryAtPath:dirPath withIntermediateDirectories:YES
                        attributes:nil error:nil];
}

+(BOOL)isFileExist:(NSString*)newFilePath isDir:(BOOL*)isDir{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:newFilePath isDirectory:isDir];
}

+(NSString *)asyncWriteFileToTmpDir:(NSString*)subDir nameGenerator:(NSString* (^)(void))generator
                            content:(NSData*)content didFinish:(dispatch_block_t)block{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:subDir];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL *isDir = NULL;
    if (![manager fileExistsAtPath:path isDirectory:isDir]) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES
                            attributes:nil error:nil];
    }
    
    NSString *fullPath = [path stringByAppendingString:generator()];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [manager createFileAtPath:fullPath contents:content attributes:nil];
        if (block) {
            block();
        }
    });
    
    return fullPath;
}

@end
