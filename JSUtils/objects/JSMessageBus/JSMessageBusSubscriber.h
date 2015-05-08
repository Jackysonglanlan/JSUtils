//
//  JSMessageBusSubscriber.h
//  JSUtils
//
//  Created by Song Lanlan on 1/5/15.
//  Copyright (c) 2015 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSMBOperator.h"

/**
 * Represent classes that want to participate the message bus' message porcessing process.
 */
@interface JSMessageBusSubscriber : NSObject

/**
 * The higher value, the lower priority it is.
 */
@property(nonatomic,assign) NSInteger priority;

/**
 * Called when Subscriber will start processing a message.
 */
@property(nonatomic,copy) void (^willStartProcessingMessage)(id message);

/**
 * Block to filter the message you want.
 * @return YES if you want to handle this message.
 */
@property(nonatomic,copy) BOOL (^messageFilter)(id message);

/**
 * This block will be called with the message if the messageFilter block returns YES.
 */
@property(nonatomic,copy) void (^messageHandler)(id message, JSMBOperator *busOperator);

@end
