//
//  JSIncrementalFileReader.h
//
//  Created by jackysong on 14-9-15.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Useful tool to read a "growing" file.
 */
@interface JSIncrementalFileReader : NSObject

// how long to check if there are new data when read to file end, default is 0.5s
@property(nonatomic,assign) NSTimeInterval waitingIntervalInSec;

// called when has read some data
@property(nonatomic,copy) void (^onRead)(NSData *data, NSUInteger currentPos, NSUInteger fileCurrSize);

// called when there's no more data to read
@property(nonatomic,copy) void (^onWaitMore)(void);

// called when error occurs
@property(nonatomic,copy) void (^onError)(NSError *error);

// called when the reading has stopped
@property(nonatomic,copy) void (^didStop)(void);

// multi-invoke this method is useless: if it hasn't stop, this method just return
-(void)startIncrementalReadFile:(NSString*)path chunkSize:(NSUInteger)size;

-(void)stop;

@end
