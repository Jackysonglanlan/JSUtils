//
//  NSString+SLLEnhance.h
//
//  Created by Song Lanlan on 11-2-28.
//  Copyright 2011 Jacky.Songlanlan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(SLLEnhance)

/////////// Java Suger //////////

#pragma mark - Java Suger

-(BOOL)startsWith:(NSString*)str;

-(BOOL)endsWith:(NSString*)str;

- (NSString*)replaceAll:(NSString*)regex with:(NSString*)replacement;

- (NSInteger)jsIndexOf:(NSString*)string;

- (NSInteger)indexOf:(NSString*)str fromIndex:(NSUInteger)index;

- (NSInteger)lastIndexOf:(NSString*)string;

- (NSInteger)lastIndexOf:(NSString*)str fromIndex:(NSUInteger)index;

- (NSString*)trim;

- (NSString*)replace:(NSString *)what with:(NSString *)with;

- (NSString*)substring:(NSInteger)start;
- (NSString*)substring:(NSInteger)start length:(NSInteger)length;
- (NSArray*)split:(NSString *)separator;

/////////// Helpers //////////

#pragma mark - Helpers

// if the string has some special chars like "emoji" character, this method can guarantee those chars remain,
// won't be cut in the middle(thus the whole string is illegal)
-(NSString*)jsSafeCutStringToIndex:(NSUInteger)endIndex;

- (NSUInteger)jsHexStringToUInt;

- (void)jsLoadAsNibTo:(id)owner bundle:(NSBundle*)bundle options:(NSDictionary*)options;

// Support group matching.
// For the block: groupNum identifies all the matching groups, 0 means the string itself.
// When you want stop matching, return YES, otherwise, return NO.
- (void)jsMatchesRegex:(NSString*)regex option:(NSRegularExpressionOptions)options error:(NSError**)error block:(BOOL (^)(NSString* hitString, NSUInteger groupNum))block;

// return chineses string length by chinese char
-(NSUInteger)jsWeiboWordCount;

- (NSArray*)jsArrayWithWordTokenize;

/////////// Encode / Decode //////////

#pragma mark - encode / decode

-(NSString*)jsURLEncode;

-(NSString *)jsURLDecode;

-(NSString*)jsMD5;

-(NSString*)jsSHA256;

/////////// Path //////////

#pragma mark - path

+(NSString*)jsPathForDir:(NSSearchPathDirectory)dir;

/** Creates a unique filename that can be used for one temporary file or folder.
 The returned string is different on every call. It is created by combining the result from temporaryPath with a unique UUID.
 @return The generated temporary path.
 */
+(NSString*)jsPathGenerateForTemporaryFileWithExtension:(NSString*)ext;


/////////// Other //////////

#pragma mark - other
+(NSString*)randomAlphaNumericString:(NSUInteger)evenNumLength;

- (NSRegularExpression*)toRegexExpression:(NSRegularExpressionOptions)options error:(NSError**)error;

- (BOOL)jsIsNullOrEmpty;

+ (NSString *)jsStringFromInteger:(NSInteger)anInteger;

+ (NSString *)jsStringFromFloat:(float_t)aFloat;

+ (NSString *)jsStringFromDouble:(double)aDouble;

- (NSString *)jsStringByAddingPercentEscapes;

- (NSString *)jsStringByTruncatingWith:(NSString *)truncateString measuringAgainstFont:(UIFont *)font
                              forWidth:(CGFloat)width;

-(CGSize)jsStringSizeWithFont:(UIFont*)font lineBreakMode:(NSLineBreakMode)lineBreakMode forWidth:(CGFloat)width;

+ (NSURL *)jsFileURLPathInBundle:(NSString*)bundleFileName dirInBundle:(NSString*)dir fileName:(NSString *)fileName;


-(BOOL)jsIsContainsEmoji;

/**
 * 过滤系统表情字符
 */
- (NSString*)jsFilterEmoji;
@end

