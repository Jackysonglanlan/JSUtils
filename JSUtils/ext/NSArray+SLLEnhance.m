//
//  NSArray+SLLEnhance.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-20.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import "NSArray+SLLEnhance.h"

@implementation NSArray(SLLEnhance)

/////////// Closure //////////
#pragma mark -
#pragma mark other

- (NSArray*)jsShuffle{
	NSMutableArray *result = [NSMutableArray arrayWithArray:self];
	
	for (NSUInteger i = [self count]-1; i>1; i--) {
		int randNum = arc4random() % i;
		id obj = [result objectAtIndex: i-1];
		id obj2 = [result objectAtIndex: randNum];
		[result replaceObjectAtIndex:i-1 withObject:obj2];
		[result replaceObjectAtIndex:randNum withObject:obj];
	}
	
	return result;
}

- (BOOL)jsIsEmpty{
  return ([self count] == 0);
}

@end

////////////////////////////////////////
/////// NSMutableArray ////////
////////////////////////////////////////


@implementation NSMutableArray(SLLEnhance)

/////////// Queue //////////
#pragma mark -
#pragma mark Queue

- (void)enqueue:(id)object {
	[self insertObject:object atIndex:0];
}

- (id)dequeue {
	id lastObject = [self lastObject];
	[self removeLastObject];
	return lastObject;
}

@end
