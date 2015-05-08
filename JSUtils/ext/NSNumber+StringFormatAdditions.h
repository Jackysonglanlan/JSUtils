//
//  NSNumber+StringFormatAdditions.h
//
//  Created by Nick Forge on 30/01/10.
//  Copyright 2010 Nick Forge. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSNumber (NSNumber_StringFormatAdditions)

- (NSString *)jsStringWithNumberStyle:(NSNumberFormatterStyle)style;

+ (NSNumber *)jsNumberWithString:(NSString *)string numberStyle:(NSNumberFormatterStyle)style;

@end
