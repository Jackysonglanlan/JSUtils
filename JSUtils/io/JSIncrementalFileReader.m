//
//  JSIncrementalFileReader.m
//
//  Created by jackysong on 14-9-15.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "JSIncrementalFileReader.h"

#import "JSFileIO.h"

@implementation JSIncrementalFileReader{
    dispatch_queue_t readWorker;
    
    //    NSUInteger cursor, readLen;
    BOOL isRunning;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        readWorker = dispatch_queue_create("JSIncrementalFileReader_worker", DISPATCH_QUEUE_SERIAL);
        self.waitingIntervalInSec = 0.5;
    }
    return self;
}

- (void)dealloc{
    if (readWorker) {
        dispatch_release(readWorker);
        readWorker = nil;
    }
    
    JS_releaseSafely(_onRead);
    JS_releaseSafely(_onWaitMore);
    JS_releaseSafely(_onError);
    JS_releaseSafely(_didStop);
    
    [super dealloc];
}

// return nil if error happened
-(NSFileHandle*)getFileHandle:(NSString*)path{
    NSError *error = nil;
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:path] error:&error];
    
    if (error) {
        if (self.onError) {
            self.onError(error);
        }
        return nil;
    }
    
    return handle;
}

-(void)resetStatusForNextTimeUse{
    
}

-(void)startIncrementalReadFile:(NSString*)path chunkSize:(NSUInteger)size{
    if (isRunning) return;
    
    if (size == 0) JS_Stub_Throw(@"Error Parameter:", @"The chunkSize *must* > 0");
    
    dispatch_async(readWorker, ^{
        isRunning = YES;
        
        NSFileHandle *handle = [self getFileHandle:path];
        
        if (!handle) { // error happen
            [self stop];
            return ;
        }
        
        NSUInteger fileCurrSize = [JSFileIO getFileSize:path];
        
        NSUInteger cursor = 0, readLen = size;
        
        while (isRunning) {
            BOOL isFileSizeDecrease = (cursor > fileCurrSize);
            if (isFileSizeDecrease) {
                // TODO how to do? this should NOT happen
            }
            
            BOOL isEOF = (cursor == fileCurrSize);
            if (isEOF) {// no data to read
                self.onWaitMore();
                
                [NSThread sleepForTimeInterval:self.waitingIntervalInSec];
                
                readLen = size; // recover to size
                
                // check file size again
                fileCurrSize = [JSFileIO getFileSize:path];
                
                continue;
            }
            
            readLen = (cursor + readLen < fileCurrSize) ? size : fileCurrSize - cursor;
            
            NSRange readRange = NSMakeRange(cursor, readLen);
            self.onRead([JSFileIO syncReadFileWithHandle:handle range:readRange], cursor, fileCurrSize);
            cursor += readLen;
        }
        
        [handle closeFile];
        
        [self resetStatusForNextTimeUse];
        
        if (self.didStop) self.didStop();
    });
}

-(void)stop{
    isRunning = NO;
}

@end
