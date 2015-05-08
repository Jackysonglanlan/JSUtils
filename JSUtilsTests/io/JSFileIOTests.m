//
//  JSAsyncFileIOTests.m
//  JSUtils
//
//  Created by jackysong on 14-3-28.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"
#import "JSFileIO.h"

@interface JSFileIOTests : AbstractTests

@end

@implementation JSFileIOTests{
    JSFileIO *fileIO;
    NSURL *testFile;
}

- (void)before{
    fileIO = [JSFileIO new];
    testFile = [[[self testBundle] URLForResource:@"TestStringFile" withExtension:@"txt"] retain];
    [self beginAsyncOperation];
}

- (void)after{
    [self waitForAsyncOperationOrTimeoutWithDefaultInterval];
    JS_releaseSafely(fileIO);
    JS_releaseSafely(testFile);
}

-(void)testSyncReadFile{
    NSData *data = [JSFileIO syncReadFileAtPath:[testFile path] range:NSMakeRange(1000, 30)];
    [[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] log];
}

- (void)testAsyncReadFile{
    [fileIO asyncReadFile:[testFile path] chunkSize:10 range:NSMakeRange(1000, 30)
                  process:^(NSData *data, NSUInteger total) {
                      [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] log];
                      NSLog(@"total:%u",total);
                  }
                   finish:^{
                       [@"finish" log];
                   }
                  failure:^{
                      [@"failure" log];
                  }];
}

- (void)testAsyncAppendFile{
    NSString *path = [NSTemporaryDirectory() stringByAppendingString:@"testAsyncAppendFile/copy.txt"];
    
    [fileIO asyncAppendFileWithData:[NSData dataWithContentsOfURL:testFile]
                             toPath:path
                            process:^(NSData *dataHasWritten) {
                                NSLog(@"has written bytes:%u", dataHasWritten.length);
                            }
                             finish:^{
                                 [@"finish" log];
                             }
                            failure:^(int errorCode){
                                NSLog(@"error code: %d",errorCode);
                            }];
}

@end
