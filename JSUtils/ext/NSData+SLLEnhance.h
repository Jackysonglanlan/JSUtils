//
//  NSData+SLLEnhance.h
//  TempDemo
//
//  Created by Song Lanlan on 13-8-23.
//  Copyright (c) 2013 tiantian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(SLLEnhance)

-(NSString*)jsDetectImageSuffix;

-(NSString*)jsToStringWithEncoding:(CFStringEncodings)encoding;

-(NSString*)jsMD5;

-(NSString*)jsSHA256;

/**
 * Remember to *free* the byte array when you are done!
 */
-(Byte*)jsCopyBytes;

@end
