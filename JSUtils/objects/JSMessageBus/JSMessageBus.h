//
//  JSMessageBus.h
//  JSUtils
//
//  Created by Song Lanlan on 1/5/15.
//  Copyright (c) 2015 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSMessageBusSubscriber.h"

@interface JSMessageBus : NSObject

+ (instancetype)defaultMessageBus;

+ (instancetype)messageBusOfReuseIdentifier:(NSString*)reuseId;

/**
 * Called when Message Bus has finished processing a message.
 */
@property(nonatomic,copy) void (^didFinishProcessingMessage)(id message);

/**
 * Called when Message Bus has finished processing *all* messages in its queue.
 */
@property(nonatomic,copy) void (^didFinishProcessingAllMessages)(void);

/**
 * Publish message to message bus, this message will be passed from high priority to low priority subscriber,
 * one by one.
 */
-(void)publish:(id)message;

-(void)registerSubscriber:(JSMessageBusSubscriber*)subscriber;

@end

