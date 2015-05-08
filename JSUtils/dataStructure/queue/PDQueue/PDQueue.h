//
//  PDPriorityQueue.h
//  PocketDiary
//
//  Created by takiuchi on 08/10/06.
//  Copyright 2008 s21g LLC. All rights reserved.
//

@class PDQueueNode;

@interface PDQueue : NSObject <NSFastEnumeration>

@property (nonatomic, assign, readonly) PDQueueNode *head;
@property (nonatomic, assign, readonly) PDQueueNode *tail;

- (NSUInteger)size;
- (PDQueueNode*)push:(id)object;
- (id)pop;
- (PDQueueNode*)unshift:(id)object;
- (id)shift;
- (void)remove:(PDQueueNode*)node;
- (void)clear;
- (NSArray *)sortedArrayUsingSelector:(SEL)comparator;

@end
