//
//  StreamWriter.h
//  DCSModule
//
//  Created by jacky.song on 12-10-9.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StreamWriterDelegate <NSObject>

-(NSMutableData*)dataToWrite;

-(void)didOccurError:(NSError*)error;

@optional
-(void)didFinishWritingData:(NSOutputStream*)stream;

@end

@interface StreamWriter : NSObject<NSStreamDelegate>{
@private
  NSUInteger byteIndex;
  NSOutputStream *outputStream;
}

-(id)initWithOutputStream:(NSOutputStream*)os;

@property(nonatomic,assign) id<StreamWriterDelegate> delegate;
@property(nonatomic,assign) NSUInteger bytesWrite;
@property(nonatomic,readonly) NSStreamStatus status;

// default is YES
@property(nonatomic,assign) BOOL closeStreamAfterEndEncountered;

-(void)startWriting;

@end
