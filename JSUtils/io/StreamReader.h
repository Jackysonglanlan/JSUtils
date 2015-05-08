//
//  StreamReader.h
//  DCSModule
//
//  Created by jacky.song on 12-10-9.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StreamReaderDelegate <NSObject>

-(void)processIncomingData:(const void *)dataSegments length:(NSUInteger)length;

-(void)didOccurError:(NSError*)error;

@optional
-(void)didFinishReadingData;

@end


@interface StreamReader : NSObject<NSStreamDelegate>{
@private
  NSInputStream *inputStream;
}

-(id)initWithInputStream:(NSInputStream*)is; 

@property(nonatomic,assign) id<StreamReaderDelegate> delegate;
@property(nonatomic,assign) NSUInteger bytesRead;
@property(nonatomic,readonly) NSStreamStatus status;

// default is YES
@property(nonatomic,assign) BOOL closeStreamAfterEndEncountered;

-(void)startReading;

@end
