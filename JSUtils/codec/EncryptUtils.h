//
//  EncryptUtils.h
//  QMQZ
//
//  Created by admin on 15/1/28.
//  Copyright (c) 2015年 cmge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptUtils : NSObject

+ (NSString*)encrptyStringUsingAES256:(NSString*)origString;

+ (NSString*)decryptStringUsingAES256FromEncryptString:(NSString*)origString;

@end
