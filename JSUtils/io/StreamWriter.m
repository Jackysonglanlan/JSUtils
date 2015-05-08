//
//  StreamWriter.m
//  DCSModule
//
//  Created by jacky.song on 12-10-9.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import "StreamWriter.h"

#define kValue_BufferSize (1024 * 4)

@implementation StreamWriter
@synthesize delegate,status,closeStreamAfterEndEncountered;

-(id)initWithOutputStream:(NSOutputStream*)os{
  self = [super init];
  if (self) {
    outputStream = [os retain];
    closeStreamAfterEndEncountered = YES;
    [self configStream];
  }
  return self;
}

- (void)dealloc{
  [super dealloc];
}


-(void)startWriting{
  [outputStream open];
}

-(NSStreamStatus)status{
  return outputStream.streamStatus;
}

#pragma mark - private

-(void)configStream{
  [outputStream setDelegate:self];
  [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)doHasSpaceAvailable:(NSOutputStream*)stream{
  NSMutableData *data = [delegate dataToWrite];
  
  uint8_t *bytesToWrite = (uint8_t *)[data mutableBytes];
  
  // move pointer to the start point of this time's writing
  bytesToWrite += byteIndex;
  
  // get the total length of data
  int data_len = [data length];
  
  // length of data block that prepare to write
  unsigned int len = MIN(data_len - byteIndex, kValue_BufferSize);
    
  // copy data block to buffer
  uint8_t buf[len];
  (void)memcpy(buf, bytesToWrite, len);
  
  len = [stream write:(const uint8_t *)buf maxLength:len];
  
  byteIndex += len;
}


-(void)doEndEncountered:(NSOutputStream*)stream{
  if ([delegate respondsToSelector:@selector(didFinishWritingData:)]) {
    [delegate didFinishWritingData:stream];
  }
  
  if (!closeStreamAfterEndEncountered) {
    return;
  }
  
  [stream close];
  
  [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSDefaultRunLoopMode];
  [stream release];
  stream = nil; // stream is ivar, so reinit it
}


-(void)doErrorOccurred:(NSOutputStream*)stream{
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
  NSOutputStream *stream = (NSOutputStream *)s;
  switch(eventCode) {
    case NSStreamEventHasSpaceAvailable:
    {
      [self doHasSpaceAvailable:stream];
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
