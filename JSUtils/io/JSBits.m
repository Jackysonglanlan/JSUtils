//
//  JSBits.m
//  DCSModule
//
//  Created by jacky.song on 12-10-25.
//  Copyright (c) 2012 symbio.com. All rights reserved.
//

#import "JSBits.h"

void hex_print(uint8_t *data, int length);
void bit_print(uint8_t *data, int start, int length);

@implementation JSBits

void hex_print(uint8_t *data, int length){
	int ptr = 0;
	for(;ptr < length;ptr++){
		printf("0x%02x ",(uint8_t)*(data+ptr));
	}
	printf("\n");
}

void bit_print(uint8_t *data, int start, int length){
	uint8_t mask = 0x01;
	int ptr = 0;
	int bit = 0;
  data += start;
  
	for(;ptr < length;ptr++){
		for(bit = 7;bit >= 0;bit--){
			if ((mask << bit) & (uint8_t)*(data+ptr)){
				printf("1");
			}
			else{
				printf("0");
			}
		}
		printf(" ");
	}
	printf("\n");
}

#pragma mark - read bytes

+(uint64_t)getBitsValueFrom:(uint64_t)value validBitCount:(NSUInteger)bCount range:(NSRange)range{
    // move left
    value = value << ((64 - bCount) + (range.location - 1));
    // then move right
    value = value >> (64 - range.length);
    
    return value;
}

+(uint16_t)readInt16:(Byte*)buffer{
  uint16_t iValue = 0;
  int size = sizeof(iValue);
  for (int i=0; i<size; i++) {
    iValue |= (*buffer & 0xff) << 8*(size-i-1);
    buffer++;
  }
  return iValue;
}

+(uint32_t)readInt32:(Byte*)buffer{
  uint32_t iValue = 0;
  int size = sizeof(iValue);
  for (int i=0; i<size; i++) {
    iValue |= (*buffer & 0xff) << 8*(size-i-1);
    
    // Using '& 0xff' to translate 1 byte: xxxxxxxx to the int like this: 00000000 00000000 00000000 xxxxxxxx
    // Then using '<<' to place the byte to the right position of the int bits like: 00000000 xxxxxxxx 00000000 00000000
    // Then finally merge it into int using '|'.
    
    buffer++;// process next byte
  }
  return iValue;
}

+(uint64_t)readInt64:(Byte*)buffer{
  uint64_t iValue = 0;
  int size = sizeof(iValue);
  for (int i=0; i<size; i++) {
    iValue |= (*buffer & 0xff) << 8*(size-i-1);
    buffer++;
  }
  return iValue;
}

#pragma mark - write bytes

+(void)writeInt32:(uint32_t)iValue buffer:(Byte*)buffer startAt:(int)index{
  int size = sizeof(iValue);
  buffer += index; // move array start pointer
  
  for (int i=0; i < size; i++) {
    *buffer = iValue >> (size-i-1)*8;// write 1 byte to buffer
    buffer++;// move current pointer
  }
}

+(void)writeInt16:(uint16_t)iValue buffer:(Byte*)buffer startAt:(int)index{
  int size = sizeof(iValue);
  buffer += index; // move array start pointer
  
  for (int i=0; i < size; i++) {
    *buffer = iValue >> (size-i-1)*8;// write 1 byte to buffer
    buffer++;// move current pointer
  }
}

+(void)writeInt64:(uint64_t)iValue buffer:(Byte*)buffer startAt:(int)index{
  int size = sizeof(iValue);
  buffer += index; // move array start pointer
  
  for (int i=0; i < size; i++) {
    *buffer = iValue >> (size-i-1)*8;// write 1 byte to buffer
    buffer++;// move current pointer
  }
}

#pragma mark - print bytes

+(void)printBits:(Byte*)buffer start:(int32_t)start length:(int32_t)length{
  bit_print(buffer, start, length);
}

+(void)printInt32Bits:(uint32_t)iValue{
  uint32_t i32 = iValue;
  uint8_t arr32[4];
  [self writeInt32:i32 buffer:arr32 startAt:0];
  bit_print(arr32, 0, 4);
}

+(void)printInt16Bits:(uint16_t)iValue{
  uint16_t i16 = iValue;
  uint8_t arr16[2];
  [self writeInt16:i16 buffer:arr16 startAt:0];
  bit_print(arr16, 0, 2);
}

+(void)printInt64Bits:(uint64_t)iValue{
  uint64_t i64 = iValue;
  uint8_t arr64[8];
  [self writeInt64:i64 buffer:arr64 startAt:0];
  bit_print(arr64, 0, 8);
}


@end
