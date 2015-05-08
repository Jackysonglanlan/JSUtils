//
//  NSData+SLLEnhance.m
//  TempDemo
//
//  Created by Song Lanlan on 13-8-23.
//  Copyright (c) 2013 tiantian. All rights reserved.
//

#import "NSData+SLLEnhance.h"
#import "HashValue.h"

@implementation NSData(SLLEnhance)

-(NSString*)jsDetectImageSuffix{
    uint8_t c;
    [self getBytes:&c length:1];
    
    NSString *imageFormat = @"";
    switch (c) {
        case 0xFF:
            imageFormat = @".jpg";
            break;
        case 0x89:
            imageFormat = @".png";
            break;
        case 0x47:
            imageFormat = @".gif";
            break;
        case 0x49:
        case 0x4D:
            imageFormat = @".tiff";
            break;
        case 0x42:
            imageFormat = @".bmp";
            break;
        default:
            break;
    }
    return imageFormat;
}

-(NSString*)jsToStringWithEncoding:(CFStringEncodings)encoding{
    NSStringEncoding sEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
    return [[[NSString alloc] initWithData:self encoding:sEncoding] autorelease];
}

-(NSString*)jsMD5{
    return [[HashValue md5HashWithData:self] description];
}

-(NSString*)jsSHA256{
    return [[HashValue sha256HashWithData:self] description];
}

-(Byte*)jsCopyBytes{
    NSUInteger len = [self length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [self bytes], len);
    return byteData;
}

@end
