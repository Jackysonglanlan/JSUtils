//
//  JSFileUtils.h
//  FastTest
//
//  Created by Song Lanlan on 13-9-27.
//  Copyright (c) 2013年 tiantian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRegex_FileExtension @"\\.[^\\.]+"

@interface JSFileUtils : NSObject

+(void)iterateFileInDir:(NSString*)dirPath doWithFile:(void (^)(NSString *filePath))block;

+(void)cleanDir:(NSString*)dirPath;

+(BOOL)isFileExist:(NSString*)newFilePath isDir:(BOOL*)isDir;

+(NSString *)asyncWriteFileToTmpDir:(NSString*)subDir nameGenerator:(NSString* (^)(void))generator
                            content:(NSData*)content didFinish:(dispatch_block_t)block;

@end

