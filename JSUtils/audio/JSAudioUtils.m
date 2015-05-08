//
//  JSAudioUtils.m
//  JSUtils
//
//  Created by jackysong on 14-3-29.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "JSAudioUtils.h"
#import "JSFileIO.h"

@implementation JSAudioUtils

+(NSFileHandle*)getFileHandlerAtPath:(NSString*)amrFilePath{
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingFromURL:[NSURL fileURLWithPath:amrFilePath] error:nil];
    return handle;
}

+(NSTimeInterval)getAMRDuration:(NSString*)amrFilePath{
    NSTimeInterval duration = -1;
    int packedSize[]  = { 12, 13, 15, 17, 19, 20, 26, 31, 5, 0, 0, 0, 0, 0, 0, 0 };
    
    NSUInteger length = [JSFileIO getFileSize:amrFilePath];
    int pos = 6;//设置初始位置
    int frameCount = 0;//初始帧数
    int packedPos = -1;

    NSFileHandle *handle = [self getFileHandlerAtPath:amrFilePath];
    
    if (!handle) return -1;
    
    Byte data[1];
    while (pos <= length) {
        NSData *pieceData = [JSFileIO syncReadFileWithHandle:handle range:NSMakeRange(pos, 1)];
        if (pieceData.length != 1) {
            duration = length > 0 ? ((length - 6) / 650) : 0;
            break;
        }
        
        [pieceData getBytes:data length:1];

        packedPos = (data[0] >> 3) & 0x0F;
        
        pos += packedSize[packedPos] + 1;
        frameCount++;
    }
    
    [handle closeFile];
    
    duration += frameCount * 20;// 一帧对应20ms
    
    return duration / 1000; // ms to seconds
}

@end
