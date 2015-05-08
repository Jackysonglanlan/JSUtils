//
//  PDLinkedListNode.h
//  PocketDiary
//
//  Created by takiuchi on 08/10/07.
//  Copyright 2008 s21g LLC. All rights reserved.
//

@interface PDQueueNode : NSObject

@property (nonatomic, assign) PDQueueNode *prev;
@property (nonatomic, assign) PDQueueNode *next;
@property (nonatomic, retain) id object;

@end
