//
//  JSAsyncFileIO.h
//  JSUtils
//
//  Created by jackysong on 14-3-28.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSFileIO : NSObject

+(NSArray*)listAllContentInPath:(NSString*)path;

+(NSUInteger)getFileSize:(NSString*)filePath;

+(BOOL)createDir:(NSString*)dirPath;

+(BOOL)deleteItemAtPath:(NSString*)filePath;

+(BOOL)cleanDir:(NSString*)dirPath;

+(BOOL)isFileExist:(NSString*)newFilePath isDir:(BOOL*)isDir;

//+(BOOL)zipFiles:(NSArray*)filePathList inArchive:(NSString*)archivePath;
//
//+(BOOL)zipFilesInDirectory:(NSString *)directoryPath inArchive:(NSString*)archivePath;

/**
 * return nil if the file can't be read for some reasons.
 */
+(NSData*)syncReadFileAtPath:(NSString*)filePath range:(NSRange)readRange;

+(NSData*)syncReadFileWithHandle:(NSFileHandle*)handle range:(NSRange)readRange;

- (void)asyncReadFile:(NSString*)filePath chunkSize:(size_t)chunkSize range:(NSRange)readRange
              process:(void (^)(NSData *data, NSUInteger totalFileSize))processBlock
               finish:(void (^)(void))finishBlock
              failure:(void (^)(void))failure;

/**
 *  If the file doesn't exist, this method will create one.
 *
 *  @param data
 *  @param toPath  Full path of the file you want to write
 *  @param process
 *  @param finish  Called when data has written to file successfully.
 *  @param failure Called with error code if something wrong happened
 */
-(void)asyncAppendFileWithData:(NSData*)data
                        toPath:(NSString*)toPath
                       process:(void (^)(NSData *dataHasWritten))process
                        finish:(void (^)(void))finish
                       failure:(void (^)(int errorCode))failure;

-(NSString *)asyncWriteFileToTmpDir:(NSString*)subDir
                      nameGenerator:(NSString* (^)(void))generator
                            content:(NSData*)content
                          didFinish:(dispatch_block_t)block;

@end
