//
//  JSIncrementalFileReaderTests.m
//  JSUtils
//
//  Created by jackysong on 14-9-15.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"

#import "JSIncrementalFileReader.h"

@interface JSIncrementalFileReaderTests : AbstractTests

@end

@implementation JSIncrementalFileReaderTests{
    NSString *testFilePath;
}

-(void)before{
    // you must create the file in simulator's tmp dir *manually* to make the test work.
    testFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/mockIncreData.txt"];
}

-(void)readAgain:(JSIncrementalFileReader*)reader{
    [@"readAgain" log];
    [reader startIncrementalReadFile:testFilePath chunkSize:10];
}

-(void)stopIt:(JSIncrementalFileReader*)reader{
    [reader stop];
    [self readAgain:reader];
}

- (void)testXXX {
    JSIncrementalFileReader *reader = [JSIncrementalFileReader new];
    
    [reader setOnRead:^(NSData *data, NSUInteger currentPos, NSUInteger fileCurrSize) {
        NSLog(@"%@ start:%u total:%u", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease],
              currentPos, fileCurrSize);
    }];
    
    __block int count = 0;
    [reader setOnWaitMore:^{
        count++;
        [@"no more ..." log];
        if (count % 4 == 0) {
            [self stopIt:reader];
        }
    }];
    
    [reader setDidStop:^{
        [@"stopped ..." log];
    }];
    
    [reader startIncrementalReadFile:testFilePath chunkSize:10];
    
    [self beginAsyncOperationWithTimeout:600];
}

@end
