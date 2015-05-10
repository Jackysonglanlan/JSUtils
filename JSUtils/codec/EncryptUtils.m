//
//  EncryptUtils.m
//  QMQZ
//
//  Created by admin on 15/1/28.
//  Copyright (c) 2015年 cmge. All rights reserved.
//

#import "EncryptUtils.h"

#import "RNEncryptor.h"
#import "RNDecryptor.h"

#import "Base64.h"

#define AES_Encrypt_Key @"s*$%8(y_jacky.song_6MS#&7^f"

@implementation EncryptUtils

+ (NSString*)encrptyStringUsingAES256:(NSString*)origString{
    NSData *data = [origString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:AES_Encrypt_Key
                                               error:nil];
    
    NSString *encryptedDataStr = [encryptedData jsBase64EncodedString];
    
    return encryptedDataStr;
}

+ (NSString*)decryptStringUsingAES256FromEncryptString:(NSString*)origString{
    NSData *encryptedData = [origString jsBase64DecodedData];
    
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                        withPassword:AES_Encrypt_Key
                                               error:nil];
    
    NSString *decryptedDataStr = [[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding] autorelease];
    
    return decryptedDataStr;
}

@end
