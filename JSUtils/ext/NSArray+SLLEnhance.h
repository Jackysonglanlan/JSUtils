//
//  NSArray+SLLEnhance.h
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-20.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SLLEnhance)

/////////// Closure //////////

- (NSArray*)jsShuffle;

- (BOOL)jsIsEmpty;

@end



////////////////////////////////////////
/////// NSMutableArray ////////
////////////////////////////////////////


@interface NSMutableArray(SLLEnhance) 

/////////// Queue //////////

- (void)enqueue:(id)object;
- (id)dequeue;

@end