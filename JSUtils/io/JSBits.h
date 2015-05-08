//
//  JSBits.h
//  DCSModule
//
//  Created by jacky.song on 12-10-25.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

@interface JSBits : NSObject

#pragma mark - read bytes

/**
 *  Parse bits according to the protocol or format.
 *
 *  @param value  The value that contains your bits
 *  @param bCount How many bits do you want to check
 *  @param range  The bits range you want to parse, range.location is 1-based.
 *
 *  @return the value that contains the bits in the range.
 */
+(uint64_t)getBitsValueFrom:(uint64_t)value validBitCount:(NSUInteger)bCount range:(NSRange)range;

+(uint16_t)readInt16:(Byte*)bytes;

+(uint32_t)readInt32:(Byte*)bytes;

+(uint64_t)readInt64:(Byte*)bytes;

#pragma mark - write bytes

+(void)writeInt32:(uint32_t)iValue buffer:(Byte*)buffer startAt:(int)index;

+(void)writeInt16:(uint16_t)iValue buffer:(Byte*)buffer startAt:(int)index;

+(void)writeInt64:(uint64_t)iValue buffer:(Byte*)buffer startAt:(int)index;

#pragma mark - print bytes

+(void)printBits:(Byte*)buffer start:(int32_t)start length:(int32_t)length;

+(void)printInt32Bits:(uint32_t)iValue;

+(void)printInt16Bits:(uint16_t)iValue;

+(void)printInt64Bits:(uint64_t)iValue;

@end