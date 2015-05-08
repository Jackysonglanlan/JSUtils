//
//  NSException+SLLEnhance.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-21.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import "NSException+SLLEnhance.h"

@implementation NSException(SLLEnhance)

- (void)generateStackTraceForException {
  NSString* processIdentifier = [[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] stringValue];
  NSString* stackAddresses = [[self callStackReturnAddresses] componentsJoinedByString:@" "];
  NSMutableString* debugInfo = [NSMutableString string];
  [debugInfo appendString:@"\n"];
  [debugInfo appendString:@"================================\n"];
  [debugInfo appendString:@"Exception Caught:\n"];
  [debugInfo appendString:@"--------------------------------\n"];
  [debugInfo appendFormat:@"Name: %@\n", self.name];
  [debugInfo appendFormat:@"Reason: %@\n", self.reason];
  if(self.userInfo) {
    [debugInfo appendFormat:@"Additional Info: %@\n", self.userInfo];
  } else {
    [debugInfo appendString:@"No additional information available..\n"];
  }
  [debugInfo appendString:@"--------------------------------\n"];
  [debugInfo appendFormat:@"Run the following command in GDB to view a full stack trace:\n\nshell atos -p %@ %@\n\n", processIdentifier, stackAddresses];
  [debugInfo appendString:@"================================\n"];
  DLog(@"%@", debugInfo);
  
  while(1) {
    // Keeps the process alive while you run the command.
  }
}

@end
