//
//  JSMsgUtils.h
//
//  Created by jackysong on 10-11-19.
//  Copyright 2010 6 Click Chengdu Corp. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JSMessageUtils : NSObject {
  
}

/*
 Publish symbio-exclusive messages. return true if succeeds.
 */
+(BOOL)publish:(NSString*)name data:(NSDictionary *) data;

/*
 Receive symbio-exclusive messages
 */
+(void)receive:(NSString*)name receiver:(id)receiver selector:(SEL)selector ;

+(void)receiveSystemNoti:(NSString *)name receiver:(id)receiver selector:(SEL)selector ;

/*
  Unregister symbio-exclusive messages
 */
+(BOOL)unreg:(NSString*)name;

+(BOOL)unreg:(NSString *)name from:(id)receiver;

+(BOOL)unregSystemMsg:(NSString *)name;

+(BOOL)unregSystemMsg:(NSString *)name from:(id)receiver;

+(id) invokeOn:(id)obj method:(SEL)method;

+(id) invokeOn:(id)obj method:(SEL)method arg1:(id)arg1;

+(id) invokeOn:(id)obj method:(SEL)method arg1:(id)arg1 arg2:(id)arg2;

@end



////////////////////////////////////////
/////// NSDictionary Enhancement ////////
////////////////////////////////////////


@interface NSDictionary(NSDictionary_JSMsgUtils)

-(void)jsPublishByMsg:(NSString *)name;

@end


////////////////////////////////////////
/////// NSString Enhancement ////////
////////////////////////////////////////

@interface NSString(NSString_JSMsgUtils)

-(void)jsRespondThisMsgBy:(id)receiver handler:(SEL)handler;

-(void)jsRespondThisSystemMsgBy:(id)receiver handler:(SEL)handler;

-(void)jsUnregisterThisMsgBy:(id)receiver;

@end



