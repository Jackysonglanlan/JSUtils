//
//  StreamReader.m
//  DCSModule
//
//  Created by jacky.song on 12-10-9.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import "StreamReader.h"

#define kValue_BufferSize (1024 * 4)

@implementation StreamReader
@synthesize bytesRead,delegate,status,closeStreamAfterEndEncountered;

-(id)initWithInputStream:(NSInputStream*)is{
  self = [super init];
  if (self) {
    inputStream = [is retain];
    bytesRead = 0;
    closeStreamAfterEndEncountered = YES;
    [self configStream];
  }
  return self;
}

- (void)dealloc{
  [super dealloc];
}


-(void)startReading{
  [inputStream open];
}


-(NSStreamStatus)status{
  return inputStream.streamStatus;
}


#pragma mark - private

-(void)configStream{
  [inputStream setDelegate:self];
  [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)doHasBytesAvailable:(NSInputStream*)stream{
  uint8_t buf[kValue_BufferSize];
  
  unsigned int len = 0;
  
  len = [stream read:buf maxLength:1024];
  
  if (len>0) {
    bytesRead += len;
    [delegate processIncomingData:buf length:len];
  }
  else {
    //        NSLog(@"no buffer!");
  }
}


-(void)doEndEncountered:(NSInputStream*)stream{
  if (!closeStreamAfterEndEncountered) {
    return;
  }
  
  [stream close];
  [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSDefaultRunLoopMode];
  [stream release];
  stream = nil; // stream is ivar, so reinit it
  
  if ([delegate respondsToSelector:@selector(didFinishReadingData)]) {
    [delegate didFinishReadingData];    
  }
}


-(void)doErrorOccurred:(NSInputStream*)stream{
  NSError *theError = [stream streamError];
  [delegate didOccurError:theError];
  
  [stream close];
  [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSDefaultRunLoopMode];
  [stream release];
  stream = nil;
}



#pragma mark delegate

- (void)stream:(NSStream *)s handleEvent:(NSStreamEvent)eventCode {
  NSInputStream *stream = (NSInputStream *)s;
  switch(eventCode) {
    case NSStreamEventHasBytesAvailable:
    {
      [self doHasBytesAvailable:stream];
      break;
    }
    case NSStreamEventEndEncountered:
    {
      [self doEndEncountered:stream];
      break;
    }
    case NSStreamEventErrorOccurred:
    {
      [self doErrorOccurred:stream];
      break;
    }
      default:{
          break;
      }
  }
}

@end
