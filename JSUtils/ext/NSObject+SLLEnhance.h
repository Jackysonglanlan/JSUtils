//
//  NSObject+SLLEnhance.h
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-20.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(SLLEnhance)

////////// Syntax sugar //////////

-(BOOL)canPerformSelector:(SEL)selector;

////////// NSRunLoop //////////


/***************************
 Perform the supplied block after a delay
 This is effectively equivalent to performSelector:afterDelay:
 @param aBlock The block to perform
 @param aInterval The time interval after which the block should be invoked
 @since M3Foundation 1.0 or later
 **************************/
- (void)jsPerformBlock:(void (^)(void))aBlock afterDelay:(NSTimeInterval)aInterval;

/***************************
 Perform the supplied block after a delay for the supplied run loop modes
 This is effectively equivalent to performSelector:afterDelay:inModes:
 @param aBlock The block to perform
 @param aInterval The time interval after which the block should be invoked
 @param aArray An array of run loop modes
 @since M3Foundation 1.0 or later
 **************************/
- (void)jsPerformBlock:(void (^)(void))aBlock afterDelay:(NSTimeInterval)aInterval inModes:(NSArray *)aArray;


////////// KVC //////////


/***************************
 Start observing multiple key paths at once
 @param aObserver The object that will observe the receiver
 @param aKeyPaths An array of key paths to observe
 @param aOptions The options to use for observing
 @param aContext A context pointer for the observation
 @since M3Foundation 1.0 or later
 **************************/
- (void)jsAddObserver:(NSObject *)aObserver forKeyPathsInArray:(NSArray *)aKeyPaths options:(NSKeyValueObservingOptions)aOptions context:(void *)aContext;

/***************************
 Stop observing multiple key paths at once
 @param aObserver The object that will stop observing the receiver
 @param aKeyPaths An array of key paths to stop observing
 @since M3Foundation 1.0 or later
 **************************/
- (void)jsRemoveObserver:(NSObject *)aObserver forKeyPathsInArray:(NSArray *)aKeyPaths;

/***************************
 Inform observers that we will change multiple keys
 @param aKeys An array of key paths that will change
 @since M3Foundation 1.0 or later
 **************************/
- (void)jsWillChangeValueForKeys:(NSArray *)aKeys;

/***************************
 Inform observers that we did change multiple keys
 @param aKeys An array of key paths that did change
 @since M3Foundation 1.0 or later
 **************************/
- (void)jsDidChangeValueForKeys:(NSArray *)aKeys;

- (void)jsRemoveCenterNotificationObserverForName:(NSString*)name;

// Shotcut for [[NSNotificationCenter defaultCenter] addObserver:self selector:...]
- (void)jsObserveCenterNotification:(NSString*)name action:(SEL)action;

@end
