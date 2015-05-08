//
//  JSMsgUtils.m
//
//  Created by jackysong on 10-11-19.
//  Copyright 2010 6 Click Chengdu Corp. All rights reserved.
//

#import "JSMessageUtils.h"

@implementation JSMessageUtils

#pragma mark publish

+(BOOL)publish:(NSString*)name data:(NSDictionary*)data{
	@try {
		[[JSMessageUtils center] postNotificationName:[JSMessageUtils exclusiveName:name] object:nil userInfo:data];
	}
	@catch (NSException * e) {
		return NO;
	}
	return YES;
}

#pragma mark receive

+(void)receive:(NSString *)name receiver:(id)receiver selector:(SEL)selector {
	[[JSMessageUtils center] addObserver:receiver selector:selector name:[JSMessageUtils exclusiveName:name] object:nil];
}

+(void)receiveSystemNoti:(NSString *)name receiver:(id)receiver selector:(SEL)selector {
	[[JSMessageUtils center] addObserver:receiver selector:selector name:name object:nil];
}

#pragma mark register

+(BOOL)unreg:(NSString *)name{
	@try {
		[[JSMessageUtils center] removeObserver:nil name:[JSMessageUtils exclusiveName:name] object:nil];
	}
	@catch (NSException * e) {
		return NO;
	}
	return YES;
}

+(BOOL)unreg:(NSString *)name from:(id)receiver{
	@try {
		[[JSMessageUtils center] removeObserver:receiver name:[JSMessageUtils exclusiveName:name] object:nil];
	}
	@catch (NSException * e) {
		return NO;
	}
	return YES;
}

+(BOOL)unregSystemMsg:(NSString *)name{
	@try {
		[[JSMessageUtils center] removeObserver:nil name:name object:nil];
	}
	@catch (NSException * e) {
		return NO;
	}
	return YES;
}

+(BOOL)unregSystemMsg:(NSString *)name from:(id)receiver{
	@try {
		[[JSMessageUtils center] removeObserver:receiver name:name object:nil];
	}
	@catch (NSException * e) {
		return NO;
	}
	return YES;
}

#pragma mark invoke

+(id) invokeOn:(id)obj method:(SEL)method{
	return [JSMessageUtils invokeOn:obj method:method arg1:nil arg2:nil];
}

+(id) invokeOn:(id)obj method:(SEL)method arg1:(id)arg1{
	return [JSMessageUtils invokeOn:obj method:method arg1:arg1 arg2:nil];
}

+(id) invokeOn:(id)obj method:(SEL)method arg1:(id)arg1 arg2:(id)arg2{
	return [obj performSelector:method withObject:arg1 withObject:arg2];
}

#pragma mark private

static NSString *exclusivePrefix = nil;
+(NSString*)exclusiveName:(NSString*)name{
  if (!exclusivePrefix) {
    exclusivePrefix = NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"];
  }
  
	return [exclusivePrefix stringByAppendingFormat:@"_%@",name];
}

+(NSNotificationCenter*) center{
	return [NSNotificationCenter defaultCenter];
	
}

@end


////////////////////////////////////////
/////// NSDictionary Enhancement ////////
////////////////////////////////////////
#pragma mark -
#pragma mark NSDictionary Enhancement

@implementation NSDictionary(NSDictionary_JSMessageUtils)

-(void)jsPublishByMsg:(NSString *)name{
	[JSMessageUtils publish:name data:self];
}

@end


////////////////////////////////////////
/////// NSString Enhancement ////////
////////////////////////////////////////
#pragma mark -
#pragma mark NSString Enhancement

@implementation NSString(NSString_JSMessageUtils)

-(void)jsRespondThisMsgBy:(id)receiver handler:(SEL)handler{
	[JSMessageUtils receive:self receiver:receiver selector:handler];
}

-(void)jsRespondThisSystemMsgBy:(id)receiver handler:(SEL)handler{
	[JSMessageUtils receiveSystemNoti:self receiver:receiver selector:handler];
}

-(void)jsUnregisterThisMsgBy:(id)receiver{
    [JSMessageUtils unreg:self from:receiver];
}

@end




