//
//  NSObject+SLLEnhance.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-20.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import "NSObject+SLLEnhance.h"


@implementation NSObject(SLLEnhance)

////////// Syntax sugar //////////

-(BOOL)canPerformSelector:(SEL)selector{
    return [self respondsToSelector:selector];
}

////////// NSRunLoop //////////
#pragma mark -
#pragma mark NSRunLoop

- (void)_m3_performBlock:(void (^)(void))aBlock {
    aBlock();
    [aBlock release];
}

#pragma mark -
#pragma mark Perform blocks

- (void)jsPerformBlock:(void (^)(void))aBlock afterDelay:(NSTimeInterval)aInterval {
    [self performSelector:@selector(_m3_performBlock:) withObject:[aBlock copy] afterDelay:aInterval];
}

- (void)jsPerformBlock:(void (^)(void))aBlock afterDelay:(NSTimeInterval)aInterval inModes:(NSArray *)aArray {
    [self performSelector:@selector(_m3_performBlock:) withObject:[aBlock copy] afterDelay:aInterval inModes:aArray];
}

////////// KVC //////////

#pragma mark -
#pragma mark Key Value Observing

- (void)jsAddObserver:(NSObject *)observer forKeyPathsInArray:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options context:(void *)context {
    for (NSString *path in keyPaths) {
        [self addObserver:observer forKeyPath:path options:options context:context];
    }
}

- (void)jsRemoveObserver:(NSObject *)observer forKeyPathsInArray:(NSArray *)keyPaths {
    for (NSString *path in keyPaths) {
        [self removeObserver:observer forKeyPath:path];
    }
}

- (void)jsWillChangeValueForKeys:(NSArray *)aKeys {
    for (NSString *key in aKeys) {
        [self willChangeValueForKey:key];
    }
}

- (void)jsDidChangeValueForKeys:(NSArray *)aKeys {
    for (NSString *key in aKeys) {
        [self didChangeValueForKey:key];
    }
}

- (void)jsRemoveCenterNotificationObserverForName:(NSString*)name {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:name object:nil];
}

- (void)jsObserveCenterNotification:(NSString*)name action:(SEL)action{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:action
                                                 name:name
                                               object:nil];
}

@end
