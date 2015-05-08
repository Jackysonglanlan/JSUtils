//
//  NSString+SLLEnhance.m
//
//  Created by Song Lanlan on 11-2-28.
//  Copyright 2011 Jacky.Songlanlan. All rights reserved.
//

#import "NSString+SLLEnhance.h"

#import "HashValue.h"

NSString *randomAlphaNumericString(NSUInteger evenValue);

@implementation NSString(SLLEnhance)

/////////// Java Suger //////////
#pragma mark -
#pragma mark Java Suger

-(BOOL)startsWith:(NSString*)str{
    return [self jsIndexOf:str] == 0;
}

-(BOOL)endsWith:(NSString*)str{
    NSInteger lastIdx = [self lastIndexOf:str];
    return lastIdx > 0 && self.length == lastIdx + str.length;
}

-(NSString*)replaceAll:(NSString*)regex with:(NSString*)replacement{
	return [self stringByReplacingOccurrencesOfString:regex
                                           withString:replacement
                                              options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

-(NSInteger)jsIndexOf:(NSString*)str{
    NSRange range = [self rangeOfString:str];
	return range.length == 0 ? NSNotFound : range.location;
}

-(NSInteger)lastIndexOf:(NSString*)str{
	return [self lastIndexOf:str fromIndex:self.length];
}

-(NSInteger)indexOf:(NSString*)str fromIndex:(NSUInteger)index{
    NSRange r = [self rangeOfString:str options:(NSLiteralSearch) range:NSMakeRange(index, self.length - index)];
    return r.length == 0 ? -1 : r.location;
}

-(NSInteger)lastIndexOf:(NSString*)str fromIndex:(NSUInteger)index{
    NSRange r = [self rangeOfString:str options:(NSBackwardsSearch) range:NSMakeRange(0, index)];
    return r.length == 0 ? -1 : r.location;
}

-(NSString*)trim{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithRange:NSMakeRange(0,0x20+1)]];
}

- (NSString*)replace:(NSString *)what with:(NSString *)with{
    return [self stringByReplacingOccurrencesOfString:what withString:with];
}

- (NSArray*)split:(NSString *)separator{
    NSArray *chunks = [self componentsSeparatedByString: separator];
    return chunks;
}

- (NSString*)substring:(NSInteger)start{
    NSRange srange=NSMakeRange(start,[self length]-start);
    return [self substringWithRange:srange];
}

- (NSString*)substring:(NSInteger)start length:(NSInteger)length{
    NSRange srange=NSMakeRange(start,length);
    return [self substringWithRange:srange];
}

#pragma mark helpers

-(NSString*)jsSafeCutStringToIndex:(NSUInteger)endIndex{
    if (self.length <= endIndex) return self;
    
    NSString *sub = [self substringToIndex:endIndex];
    
    // check the illegal char like the incomplete emoji char
    NSString *tmp = [sub jsURLEncode];
    // tmp is empty, means the content is damaged.
    if ([tmp jsIsNullOrEmpty]) {
        return [self jsSafeCutStringToIndex:endIndex + 1];
    }
    
    return sub;
}

- (NSUInteger)jsHexStringToUInt{
    NSScanner *scan = [NSScanner scannerWithString:self];
	unsigned value;
	[scan scanHexInt:&value];
	return value;
}

-(void)jsLoadAsNibTo:(id)owner bundle:(NSBundle*)bundle options:(NSDictionary*)options{
    UINib *nib = [UINib nibWithNibName:self bundle:bundle];
    [nib instantiateWithOwner:owner options:options];
}

- (void)jsMatchesRegex:(NSString*)regex option:(NSRegularExpressionOptions)options error:(NSError**)error block:(BOOL (^)(NSString* hitString, NSUInteger groupNum))block{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:regex options:options error:error];
    [exp enumerateMatchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSInteger count = [result numberOfRanges];
        for (int i=0; i<count; i++) {
            NSRange range = [result rangeAtIndex:i];
            BOOL wantStop = block([self substringWithRange:range],i);
            stop = &wantStop;
        }
    }];
}

-(NSUInteger)jsWeiboWordCount{
    NSUInteger i,n=[self length],l=0,a=0,b=0;
    unichar c;
    for(i=0;i<n;i++){
        c=[self characterAtIndex:i];
        if(isblank(c)){
            b++;
        }else if(isascii(c)){
            a++;
        }else{
            l++;
        }
    }
    
    if(a==0 && l==0) return 0;
    
    return l+(int)ceilf((float)(a+b)/2.0);
}

- (NSArray*)jsArrayWithWordTokenize{
    NSMutableArray *tokensArray = [NSMutableArray array];
    NSString *string = self;
    
    CFLocaleRef locale = CFLocaleCopyCurrent();
    CFRange range = CFRangeMake(0, [string length]);
    
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault,
                                                             (CFStringRef)string,
                                                             range,
                                                             kCFStringTokenizerUnitWordBoundary,
                                                             locale);
    
    //CFStringTokenizerTokenType tokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0);
    CFStringTokenizerTokenType tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);
    
    while (tokenType != kCFStringTokenizerTokenNone) {
        range = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        NSString *token = [string substringWithRange:NSMakeRange(range.location, range.length)];
        [tokensArray addObject:token];
        tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer);
    }
    
    CFRelease(locale);
    CFRelease(tokenizer);
    
    return tokensArray;
    
}

/////////// Encode / Decode //////////
#pragma mark encode / decode

-(NSString*)jsURLEncode{
    NSString *newString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$ '()*+,;\"<>%{}|\\^~`"),
                                                                              CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    if (newString){
        return [newString autorelease];
    }
    return @"";
}

-(NSString *)jsURLDecode{
    return [(NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8) autorelease];
}


-(NSString*)jsMD5{
    return [[HashValue md5HashWithData:[self dataUsingEncoding:NSUTF8StringEncoding]] description];
}

-(NSString*)jsSHA256{
    return [[HashValue sha256HashWithData:[self dataUsingEncoding:NSUTF8StringEncoding]] description];
}

/////////// Path //////////
#pragma mark path

+(NSString*)jsPathForDir:(NSSearchPathDirectory)dir{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(dir, NSUserDomainMask, YES);
    return ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
}

+(NSString*)jsPathGenerateForTemporaryFileWithExtension:(NSString*)ext{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    NSString *uniqueString = [NSString stringWithFormat:@"%f_%@.%@",
                              [[NSDate date] timeIntervalSince1970], newUniqueIdString, ext];
    NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent:uniqueString];
    CFRelease(newUniqueId);
    CFRelease(newUniqueIdString);
    
    return tmpPath;
}

/////////// Others //////////
#pragma mark others

NSString *randomAlphaNumericString(NSUInteger evenValue) {
    NSUInteger N = evenValue;
    
    uint8_t buf[N/2];
    char sbuf[N];
    arc4random_buf(buf, N/2);
    for (int i = 0; i < N/2; i += 1) {
        sprintf (sbuf + (i*2), "%02X", buf[i]);
    }
    return [[[NSString alloc] initWithBytes:sbuf length:N encoding:NSASCIIStringEncoding] autorelease];
}

+(NSString*)randomAlphaNumericString:(NSUInteger)evenNumLength{
    return randomAlphaNumericString(evenNumLength);
}

- (NSRegularExpression*)toRegexExpression:(NSRegularExpressionOptions)options error:(NSError**)error{
    return [NSRegularExpression regularExpressionWithPattern:self
                                                     options:options
                                                       error:error];
}

- (BOOL)jsIsNullOrEmpty {
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSString *aString = [self stringByTrimmingCharactersInSet:whitespace];
	
	return (aString.length == 0 || [@"" isEqualToString:aString]);
}

+ (NSString *)jsStringFromInteger:(NSInteger)anInteger {
	return [NSString stringWithFormat:@"%ld", (long)anInteger];
}

+ (NSString *)jsStringFromFloat:(float_t)aFloat {
	return [NSString stringWithFormat:@"%f", aFloat];
}

+ (NSString *)jsStringFromDouble:(double_t)aDouble {
	return [NSString stringWithFormat:@"%f", aDouble];
}

- (NSString *)jsStringByAddingPercentEscapes {
    
	CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	NSString *result = [NSString stringWithString:(NSString *)escapedString];
	CFRelease(escapedString);
	return result;
}

- (NSString *)jsStringByTruncatingWith:(NSString *)truncateString measuringAgainstFont:(UIFont *)font
                              forWidth:(CGFloat)width {
	
	/* First check maybe the string already fits the specified width, then we simply return it as a new NSString. */
	
	CGFloat stringWidth = [self jsStringSizeWithFont:font lineBreakMode:NSLineBreakByWordWrapping forWidth:width].width;
	if (stringWidth <= width) {
		return [NSString stringWithString:self];
	}
	
	/*
	 * Before starting modifying the long string check whether we have enough place for truncateString.
	 * If not, then we simply return truncateString, the resulting string cannot be shorter than this
	 * combination anyway.
	 */
	
	CGFloat truncateStringWidth = [truncateString jsStringSizeWithFont:font lineBreakMode:NSLineBreakByWordWrapping forWidth:width].width;
	
	if (truncateStringWidth >= width) {
		return [NSString stringWithString:truncateString];
	}
	
	/* Only now there is motivation to start modifying the string. */
	
    NSMutableString *temp = [self mutableCopy];
	
	[temp appendString:truncateString];
	stringWidth = [temp jsStringSizeWithFont:font lineBreakMode:NSLineBreakByWordWrapping forWidth:width].width;
	
    NSRange range = { temp.length - 1 - truncateString.length, 1 };
	
	while (stringWidth > width && range.location > 0) {
		
		[temp deleteCharactersInRange:range];
		range.location--;
		stringWidth = [temp jsStringSizeWithFont:font lineBreakMode:NSLineBreakByWordWrapping forWidth:width].width;
	}
	
	NSString *result = [NSString stringWithString:temp];
	[temp release];
	return result;
}

-(CGSize)jsStringSizeWithFont:(UIFont*)font lineBreakMode:(NSLineBreakMode)lineBreakMode forWidth:(CGFloat)width{
    CGSize cSize = CGSizeMake(width,2000);
    CGSize actualSize = [self sizeWithFont:font constrainedToSize:cSize lineBreakMode:lineBreakMode];
    return actualSize;
}

+ (NSURL *)jsFileURLPathInBundle:(NSString*)bundleFileName dirInBundle:(NSString*)dir fileName:(NSString *)fileName{
    NSURL *bundleUrl = [[NSBundle mainBundle] URLForResource:bundleFileName withExtension:@"bundle"];
    NSString *urlString = [NSString stringWithFormat:@"%@",bundleUrl];
    urlString = [urlString stringByAppendingPathComponent:dir];
    NSURL *url = [NSURL URLWithString:[urlString stringByAppendingPathComponent:fileName]];
    
    return url;
}

-(BOOL)jsIsContainsEmoji {
    
    __block BOOL isEomji = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             
             if (substring.length > 1) {
                 
                 const unichar ls = [substring characterAtIndex:1];
                 
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     
                     isEomji = YES;
                 }
             }
         } else if (substring.length > 1) {
             
             const unichar ls = [substring characterAtIndex:1];
             
             if (ls == 0x20e3) {
                 
                 isEomji = YES;
             }
         } else {
             
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                 
                 isEomji = YES;
                 
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 isEomji = YES;
                 
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 isEomji = YES;
                 
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 isEomji = YES;
                 
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                 
                 isEomji = YES;
                 
             }
         }
         
     }];
    return isEomji;
}


-(NSString *)jsFilterEmoji {
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"😄😃😀😊☺️😉😍😘😚😗😙😜😝😛😳😁😔😌😒😞😣😢😂😭😪😥😰😅😓😩😫😨😱😠😡😤😖😆😋😷😎😴😵😲😟😦😧😈👿😮😬😐😕😯😶😇😏😑👲👳👮👷💂👶👦👧👨👩👴👵👱👼👸😺😸😻😽😼🙀😿😹😾👹👺🙈🙉🙊💀👽💩🔥✨🌟💫💥💢💦💧💤💨👂👀👃👅👄👍👎👌👊✊✌️👋✋👐👆👇👉👈🙌🙏☝️👏💪🚶🏃💃👫👪👬👭💏💑👯🙆🙅💁🙋💆💇💅👰🙎🙍🙇🙇🎩👑👒👟👞👡👠👢👕👔👚👗🎽👖👘👙💼👜👝👛👓🎀🌂💄💛💙💜💚❤💔💗💓💕💖💞💘💌💋💍💎👤👥💬👣💭🐶🐺🐱🐭🐹🐰🐸🐯🐨🐻🐷🐽🐮🐗🐵🐒🐴🐑🐘🐼🐧🐦🐤🐥🐣🐔🐍🐢🐛🐝🐜🐞🐌🐙🐚🐠🐟🐬🐳🐋🐄🐏🐀🐃🐅🐇🐉🐎🐐🐓🐕🐖🐁🐂🐲🐡🐊🐫🐪🐆🐈🐩🐾💐🌸🌷🍀🌹🌻🌺🍁🍃🍂🌿🌾🍄🌵🌴🌲🌳🌰🌱🌼🌐🌞🌝🌚🌑🌒🌓🌔🌕🌖🌗🌘🌜🌛🌙🌍🌎🌏🌋🌌🌠⭐☀⛅☁⚡☔❄⛄🌀🌁🌈🌊🎍💝🎎🎒🎓🎏🎆🎇🎐🎑🎃👻🎅🎄🎁🎋🎉🎊🎈🎌🔮🎥📷📹📼💿📀💽💾💻📱☎📞📟📠📡📺📻🔊🔉🔈🔇🔔🔕📢📣⏳⌛⏰⌚🔓🔒🔏🔐🔑🔎💡🔦🔆🔅🔌🔋🔍🛁🛀🚿🚽🔧🔩🔨🚪🚬💣🔫🔪💊💉💰💴💵💷💶💳💸📲📧📥📤✉📩📨📯📫📪📬📭📮📦📝📄📃📑📊📈📉📜📋📅📆📇📁📂✂📌📎✒✏📏📐📕📗📘📙📓📔📒📚📖🔖📛🔬🔭📰🎨🎬🎤🎧🎼🎵🎶🎹🎻🎺🎷🎸👾🎮🃏🎴🀄🎲🎯🏈🏀⚽⚾🎾🎱🏉🎳⛳🚵🚴🏁🏇🏆🎿🏂🏊🏄🎣☕🍵🍶🍺🍻🍸🍹🍷🍴🍕🍔🍟🍗🍖🍝🍛🍤🍱🍣🍥🍙🍘🍚🍜🍲🍢🍡🍳🍞🍩🍮🍦🍨🍧🎂🍰🍪🍫🍬🍭🍯🍎🍏🍊🍋🍒🍇🍉🍓🍑🍈🍌🍐🍍🍠🍆🍅🌽🏠🏡🏫🏢🏣🏥🏦🏪🏩🏨💒⛪🏬🏤🌇🌆🏯🏰⛺🏭🗼🗾🗻🌄🌅🌃🗽🌉🎠🎡⛲🎢🚢⛵🚤🚣⚓🚀✈💺🚁🚂🚊🚉🚞🚆🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠🚧🔰⛽🏮🎰♨🗿🎪🎭📍🚩🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸🇫🇷🇪🇸🇮🇹🇷🇺🇬🇧🈯🈳🈵🈴🈲🉐🈹🈺🈶🈚🚻🚹🚺🚼🚾🚰🚮🅿♿🚭🈷🈸🈂Ⓜ🛂🛄🛅🛃🉑㊙㊗🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔✳❇❎✅✴💟🆚📳📴🅰🅱🆎🅾💠➿⛎🔯🏧💹💲💱❌❗❓❕❔⭕🔝🔚🚄🚅🚈🚇🚝🚋🚃🚎🚌🚍🚙🚘🚗🚕🚖🚛🚚🚨🚓🚔🚒🚑🚐🚲🚡🚟🚠🚜💈🚏🎫🚦🚥⚠🚧🔰⛽🏮🎰♨🗿🎪🎭📍🚩🇯🇵🇰🇷🇩🇪🇨🇳🇺🇸🇫🇷🇪🇸🇮🇹🇷🇺🇬🇧🔟🔢🔣⬆⬇⬅🔠🔡🔤🔄🔼🔽⏪⏩⏫⏬⤵⤴🆗🔀🔁🔂🆕🆙🆒🆓🆖📶🎦🈁🈯🈳🈵🈴🈲🉐🈹🈺🈶🈚🚻🚹🚺🚼🚾🚰🚮🅿♿🚭🈷🈸🈂Ⓜ🛂🛄🛅🛃🉑㊙㊗🆑🆘🆔🚫🔞📵🚯🚱🚳🚷🚸⛔❎✅💟🆚📳📴🅰🅱🆎🅾💠➿⛎🔯🏧💹💲💱❗❓❕❔⭕🔝🔚🔙🔛🔜🔃🕛🕧🕐🕜🕑🕝🕒🕞🕓🕟🕔🕠🕕🕖🕗🕘🕙🕚🕡🕢🕣🕤🕥🕦➕➖➗🔘🔗➰〰〽🔱🔺🔲🔳⚫⚪🔴🔵🔻⬜⬛🔶🔷🔸🔹"];
    NSString *tempString = [[self componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    
    return tempString;
}
@end

