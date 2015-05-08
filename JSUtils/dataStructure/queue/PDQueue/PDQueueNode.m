//
//  PDLinkedListNode.m
//  PocketDiary
//
//  Created by takiuchi on 08/10/07.
//  Copyright 2008 s21g LLC. All rights reserved.
//

#import "PDQueueNode.h"

@implementation PDQueueNode{
	PDQueueNode *_prev;
	PDQueueNode *_next;
	id _object;
}

@synthesize prev = _prev;
@synthesize next = _next;
@synthesize object = _object;

- (id)init
{
	if(![super init]) return self;
	_prev = nil;
	_next = nil;
	_object = nil;
	return self;
}

- (void)dealloc
{
	[_object release];
	[super dealloc];
}

@end
