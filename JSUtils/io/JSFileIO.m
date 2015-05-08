//
//  JSAsyncFileIO.m
//  JSUtils
//
//  Created by jackysong on 14-3-28.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "JSFileIO.h"

@implementation JSFileIO{
    dispatch_io_t readChannel, writeChannel;
    dispatch_queue_t readWorker, writeWorker;
}

- (void)dealloc{
    if (readWorker) {
        dispatch_release(readWorker);
        readWorker = nil;
    }
    
    if (writeWorker) {
        dispatch_release(writeWorker);
        writeWorker = nil;
    }
    
    [super dealloc];
}

#pragma mark public static

+(NSArray*)listAllContentInPath:(NSString*)path{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enu = [manager enumeratorAtPath:path];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *subPath in enu) {
        [arr addObject:subPath];
    }
    return arr;
}

+(NSUInteger)getFileSize:(NSString*)fileFullPath{
    NSNumber* theSize;
    NSInteger fileSize = 0;
    
    if ([[NSURL fileURLWithPath:fileFullPath] getResourceValue:&theSize forKey:NSURLFileSizeKey error:nil])
        fileSize = [theSize integerValue];
    return fileSize;
}

+(BOOL)createDir:(NSString*)dirPath{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager createDirectoryAtPath:dirPath withIntermediateDirectories:YES
                               attributes:nil error:nil];
}

+(BOOL)deleteItemAtPath:(NSString*)filePath{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:filePath error:nil];
}

+(BOOL)cleanDir:(NSString*)dirPath{
    [self deleteItemAtPath:dirPath];
    return [self createDir:dirPath];
}

+(BOOL)isFileExist:(NSString*)newFilePath isDir:(BOOL*)isDir{
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:newFilePath isDirectory:isDir];
}

//+(BOOL)zipFiles:(NSArray*)filePathList inArchive:(NSString*)archivePath{
//    return [SSZipArchive createZipFileAtPath:archivePath withFilesAtPaths:filePathList];
//}
//
//+ (BOOL)zipFilesInDirectory:(NSString *)directoryPath inArchive:(NSString*)archivePath{
//    return [SSZipArchive createZipFileAtPath:archivePath withContentsOfDirectory:directoryPath];
//}

+(NSData*)syncReadFileAtPath:(NSString*)filePath range:(NSRange)readRange{
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:filePath] error:nil];

    NSData *data = [self syncReadFileWithHandle:handle range:readRange];
    
    [handle closeFile];
    
    return data;
}

+(NSData*)syncReadFileWithHandle:(NSFileHandle*)handle range:(NSRange)readRange{
    NSData* data = nil;
    
    [handle seekToFileOffset:readRange.location];
    data = [handle readDataOfLength:readRange.length];
    
    return data;
}

#pragma mark private

-(void)lazyCreateReadWorker{
    if (!readWorker) {
        readWorker = dispatch_queue_create(__PRETTY_FUNCTION__, DISPATCH_QUEUE_SERIAL);
    }
}

-(void)lazyCreateWriteWorker{
    if (!writeWorker) {
        writeWorker = dispatch_queue_create(__PRETTY_FUNCTION__, DISPATCH_QUEUE_SERIAL);
    }
}

-(NSString*)parseDirFromPath:(NSString*)path{
    NSArray *tmp = [path pathComponents];
    NSString *fileName = [tmp lastObject];
    NSString *dir = [path substringToIndex:path.length - fileName.length -1];
    return dir;
}

#pragma mark public

- (void)asyncReadFile:(NSString*)filePath chunkSize:(size_t)chunkSize range:(NSRange)readRange
              process:(void (^)(NSData *data, NSUInteger totalFileSize))processBlock
               finish:(void (^)(void))finishBlock
              failure:(void (^)(void))failure{
    [self lazyCreateReadWorker];
    
    // Open the channel.
    readChannel = dispatch_io_create_with_path(DISPATCH_IO_RANDOM,
                                               [filePath UTF8String],   // Convert to C-string
                                               O_RDONLY,                // Open for reading
                                               0,                       // No extra flags
                                               readWorker,
                                               ^(int error){
                                                   // Cleanup code
                                                   if (error == 0) {
                                                       dispatch_release(readChannel);
                                                       readChannel = nil;
                                                   }
                                               });
    
    // If the file channel could not be created, just abort.
    
    if (!readChannel){
        if (failure) failure();
        return;
    }
    
    // Get the file size.
    
    NSInteger fileSize = [self.class getFileSize:filePath];
    
    // read file randomly
    off_t currentOffset = readRange.location;
    NSUInteger rangeEnd = readRange.location + readRange.length;
    NSUInteger endOffset = (rangeEnd <= fileSize) ? rangeEnd : fileSize;
    for (;currentOffset < endOffset; currentOffset += chunkSize) {
        dispatch_io_read(readChannel, currentOffset, chunkSize, readWorker,
                         ^(bool done, dispatch_data_t dData, int error){
                             if (error)
                                 return;
                             
                             dispatch_data_apply(dData, (dispatch_data_applier_t)^(dispatch_data_t region, size_t offset,
                                                                                   const void *buffer, size_t size){
                                 
                                 NSData *data = [NSData dataWithBytes:buffer length:size];
                                 
                                 processBlock(data, fileSize);
                                 
                                 BOOL isReadAllData = (currentOffset + size == fileSize);
                                 if (isReadAllData){
                                     dispatch_io_close(readChannel, DISPATCH_IO_STOP);
                                     if (finishBlock) finishBlock();
                                 }
                                 
                                 return true;  // Keep processing if there is more data.
                             });
                         });
    }
}

-(void)asyncAppendFileWithData:(NSData*)data
                        toPath:(NSString*)toPath
                       process:(void (^)(NSData *dataHasWritten))process
                        finish:(void (^)(void))finish
                       failure:(void (^)(int errorCode))failure{
    [self lazyCreateWriteWorker];
    
    NSString *toDir = [self parseDirFromPath:toPath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL *isDir = NULL;
    if (![manager fileExistsAtPath:toDir isDirectory:isDir]) {
        [manager createDirectoryAtPath:toDir withIntermediateDirectories:YES
                            attributes:nil error:nil];
    }
    
    dispatch_fd_t fd = open([toPath UTF8String], O_RDWR | O_CREAT | O_APPEND, S_IRWXU | S_IRWXG | S_IRWXO);
    dispatch_data_t dData = dispatch_data_create([data bytes], data.length, writeWorker, NULL);
    dispatch_write(fd, dData, writeWorker,
                   ^(dispatch_data_t data, int error) {
                       dispatch_data_apply(dData, (dispatch_data_applier_t)^(dispatch_data_t region, size_t offset,
                                                                             const void *buffer, size_t size){
                           
                           NSData *data = [NSData dataWithBytes:buffer length:size];
                           if (process) process(data);
                           return true;  // Keep processing if there is more data.
                       });
                       
                       if (error != 0) {
                           if (failure) failure(error);
                       }
                       else{
                           if (finish) finish();
                       }
                   });
}

-(NSString *)asyncWriteFileToTmpDir:(NSString*)subDir nameGenerator:(NSString* (^)(void))generator
                            content:(NSData*)content didFinish:(dispatch_block_t)block{
    [self lazyCreateWriteWorker];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:subDir];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL *isDir = NULL;
    if (![manager fileExistsAtPath:path isDirectory:isDir]) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES
                            attributes:nil error:nil];
    }
    
    NSString *fullPath = [path stringByAppendingString:generator()];
    dispatch_async(writeWorker, ^{
        [manager createFileAtPath:fullPath contents:content attributes:nil];
        if (block) {
            block();
        }
    });
    
    return fullPath;
}

@end
