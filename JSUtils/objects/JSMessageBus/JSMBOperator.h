//
//  JSMBOperator.h
//  JSUtils
//
//  Created by Song Lanlan on 8/5/15.
//  Copyright (c) 2015 Song Lanlan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSMBOperator : NSObject

/**
 * Call this method when you finish handling the message, then the message will be passed to next subscriber.
 */
- (void)pass:(id)message;

/**
 * Forward message to the subscriber of specified priority.
 * This method can be used as "jump" operation: you can bypass some subscribers.
 */
- (void)forward:(id)message toSubscriberWithPriority:(NSInteger)priority;

/**
 * Tell Message Bus finish processing message, no other subscribers will get this message.
 */
- (void)finishBus:(id)message;

@end
