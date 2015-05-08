//
//  JSObjUtils.m
//
//  Created by jackysong on 10-11-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JSNSObjectUtils.h"

@implementation JSNSObjectUtils

+ (NSValue *)jsStructToObj:(const void *)structData objCType:(const char *)type{
	return [NSValue valueWithBytes:structData objCType:type];
}

+ (void)jsStructFromObj:(NSValue *)wrapper value:(void *)structValue{
	[wrapper getValue:structValue];
}

@end
