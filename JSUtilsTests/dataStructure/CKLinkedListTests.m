//
//  CFLinkedListTests.m
//  JSUtils
//
//  Created by jackysong on 14-10-8.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import "AbstractTests.h"
#import "CKLinkedList.h"

@interface CKLinkedListTests : AbstractTests

@end

@implementation CKLinkedListTests

/*
 Tests these functions:
 - (id)init;                                // init an empty list
 - (id)initWithObject:(id)anObject;         // init the linked list with a single object
 */
-(void) test_init {
    
    CKLinkedList *list1 = [[CKLinkedList alloc] init];
    assert(list1);
    assert([list1 count] == 0);
    assert([list1 lastObject] == nil);
    assert([list1 secondLastObject] == nil);
    
    CKLinkedList *list2 = [[CKLinkedList alloc] initWithObject:@"NSString"];
    assert(list2);
    assert([list2 count] == 1);
    assert([list2 lastObject] != nil);
    assert([list2 secondLastObject] == nil);
    
}


/*
 Tests these functions:
 - (void)pushBack:(id)anObject;             // add an object to back of list
 - (void)pushFront:(id)anObject;            // add an object to front of list
 - (void)addObject:(id)anObject;            // same as pushBack
 - (id)popBack;                             // remove object at end of list (returns it)
 - (id)popFront;                            // remove object at front of list (returns it)
 - (void)removeNode:(LNode *)aNode;         // remove a given node
 - (BOOL)removeObjectEqualTo:(id)anObject;  // removes object equal to anObject, returns (YES) on success
 - (void)removeAllObjects;                  // clear out the list
 - (void)dumpList;                          // dumps all the pointers in the list to NSLog
 - (BOOL)containsObject:(id)anObject;       // (YES) if passed object is in the list, (NO) otherwise
 - (void)pushNodeBack:(LNode *)n;           // adds a node object to the end of the list
 - (void)pushNodeFront:(LNode *)n;          // adds a node object to the beginning of the list
 - (void)prependObject:(id)anObject;
 - (void)appendObject:(id)anObject;
 */
-(void) test_add_remove{
    
    CKLinkedList *list = [[CKLinkedList alloc] init];
    NSString *str1 = @"This is a test string";
    NSString *str2 = @"This is another test string";
    
    assert(list);
    
    assert([list firstNode] == nil);
    assert([list lastNode] == nil);
    assert([list lastObject] == nil);
    assert([list secondLastObject] == nil);
    
    [list pushBack:str1];
    assert([list count] == 1);
    assert([list containsObject:str1]);
    assert([list lastObject] != nil);
    assert([list secondLastObject] == nil);
    
    [list pushFront:str2];
    assert([list count] == 2);
    assert([list containsObject:str2]);
    assert([list lastObject] != nil);
    assert([list secondLastObject] != nil);
    assert([[list allObjects] count] == [list count]);
    assert([[list allObjects] lastObject] == [list lastObject]);
    
    
    [list removeObjectEqualTo:str1];
    assert([list count] == 1);
    assert(![list containsObject:str1]);
    assert([[list allObjects] count] == [list count]);
    assert([[list allObjects] lastObject] == [list lastObject]);
    
    
    [list removeAllObjects];
    assert([list count] == 0);
    
    const int FILL_COUNT = 100;
    
    for (int i = 0; i < FILL_COUNT; i++) {
        assert([[list allObjects] count] == [list count]);
        [list addObject:[NSString stringWithFormat:@"%d", i]];
    }
    assert([[list allObjects] count] == [list count]);
    
    assert([list count] == [list size]);
    assert([list count] == [list length]);
    assert([list count] == FILL_COUNT);
    
    id node = [list popFront];
    assert([list count] == FILL_COUNT-1);
    assert(node);
    assert([(NSString *)node isEqualToString:@"0"]);
    
    assert([[list allObjects] lastObject] == [list lastObject]);
    
    assert([[list allObjects] count] == [list count]);
    assert([[list allObjects] count] == [[list allObjectsReverse] count]);
    
    NSMutableArray *arrayOneCopy = [NSMutableArray arrayWithArray:[[[list allObjects] reverseObjectEnumerator] allObjects]];
    [arrayOneCopy removeObjectsInArray:[list allObjectsReverse]];
    assert([arrayOneCopy count] == 0);
    
    
    assert([list firstNode]->obj == [list firstObject]);
    assert([list lastNode]->obj == [list lastObject]);
    
    assert([[list allObjects] count] == [list count]);
    assert([[list allObjects] lastObject] == [list lastObject]);
    
    node = [list popBack];
    assert([list count] == FILL_COUNT-2);
    assert(node);
    assert([(NSString *)node isEqualToString:@"99"]);
    
    int c = [list count];
    
    for (int i = 0; i < FILL_COUNT/2; i++) {
        id node = [list popBack];
        BOOL success = [(NSString *)node isEqualToString:[NSString stringWithFormat:@"%d", c]];
        assert([list count] == --c);
        assert([list count] == [list size]);
        assert([list count] == [list length]);
        assert(success);
        assert([[list allObjects] lastObject] == [list lastObject]);
    }
    
    LNode *i = nil;
    int count = [list count];
    for (i = [list firstNode]; i; i=i->next) {
        assert(i);
        if (count-- == 0) {
            assert(0); // infinite loop, nslinkedlist error
        }
    }
    assert([[list allObjects] count] == [list count]);
    
    
    assert([list count] == 48);
    LNode *firstNode = [list firstNode];
    LNode *lastNode = [list lastNode];
    assert(firstNode);
    assert(lastNode);
    [list removeNode:firstNode];
    assert([list firstNode] != firstNode);
    assert([list count] == 47);
    
    [list removeNode:lastNode];
    assert([list lastNode] != lastNode);
    assert([list count] == 46);
    
    while ([list count]) {
        [list removeNode:[list firstNode]];
        assert([[list allObjects] lastObject] == [list lastObject]);
    }
    
    assert([[list allObjects] count] == [list count]);
    assert([list count] == 0);
    [list removeAllObjects];
    assert([list count] == 0);
    assert([[list allObjects] lastObject] == [list lastObject]);
    
    [list prependObject:@"test"];
    [list appendObject:@"test2"];
    
    assert([list length] == 2);
    assert([[list firstObject] isEqualToString:@"test"]);
    assert([[list lastObject] isEqualToString:@"test2"]);
    assert([[list allObjects] count] == [list count]);
    assert([[list allObjects] lastObject] == [list lastObject]);
    
    
    firstNode = [list firstNode];
    lastNode = [list lastNode];
    
    LNode *newnode1 = LNodeMake(@"newnode1", nil, nil);
    LNode *newnode2 = LNodeMake(@"newnode2", nil, nil);
    
    assert([[list allObjects] count] == [list count]);
    
    [list pushNodeBack:newnode2];
    assert([list length] == 3);
    [list pushNodeBack:newnode2];
    assert([list length] == 4);
    [list pushNodeBack:newnode2];
    assert([list length] == 5);
    [list pushNodeBack:newnode2];
    assert([list length] == 6);
    assert([[list allObjects] lastObject] == [list lastObject]);
    
    [list pushNodeFront:newnode1];
    assert([list length] == 7);
    [list pushNodeFront:newnode1];
    assert([list length] == 8);
    [list pushNodeFront:newnode1];
    assert([list length] == 9);
    [list pushNodeFront:newnode1];
    assert([list length] == 10);
    assert([[list allObjects] lastObject] == [list lastObject]);
    
    // lets test negative indexes
    assert(list.count == 10);
    assert([list objectAtIndex:-99999] == nil);
    assert([list objectAtIndex:-1] == [list lastObject]);
    assert([list objectAtIndex:-2] == [list secondLastObject]);
    assert([list objectAtIndex:-(list.count - 1)] == [list firstObject]);
    
    
    count = [list count];
    for (i = [list firstNode]; i; i=i->next) {
        assert(i);
        // NSLog(@"%@", i->obj);
        if (count-- == 0) {
            assert(0); // infinite loop, nslinkedlist error
        }
        if (count == 0) assert([list lastNode] == i);
    }
    
    
    CKLinkedList *another = [[CKLinkedList alloc] initWithObject:@"test1"];
    
    assert(another.count == 1);
    
    CKLinkedList *foo = [[CKLinkedList alloc] initWithObject:another];
    assert(foo.count == 1);
    
    assert([[foo allObjects] count] == 1);
    
    assert([[another objectAtIndex:0] isEqualToString:@"test1"]);
    
    [another pushBack:@"test2"];
    [another pushBack:@"test3"];
    [another pushBack:@"test4"];
    [another pushBack:@"test5"];
    [another pushBack:@"test6"];
    [another pushBack:@"test7"];
    [another pushBack:@"test8"];
    
    assert([[another objectAtIndex:7] isEqualToString:@"test8"]);
    assert([[another objectAtIndex:6] isEqualToString:@"test7"]);
    assert([[another objectAtIndex:5] isEqualToString:@"test6"]);
    assert([[another objectAtIndex:4] isEqualToString:@"test5"]);
    assert([[another objectAtIndex:1] isEqualToString:@"test2"]);
    
    // more negative indexing testing
    assert([another objectAtIndex:-1] == [another objectAtIndex:7]);
    assert([another objectAtIndex:-2] == [another objectAtIndex:6]);
    assert([another objectAtIndex:-3] == [another objectAtIndex:5]);
    assert([another objectAtIndex:-4] == [another objectAtIndex:4]);
    assert([another objectAtIndex:-5] == [another objectAtIndex:3]);
    assert([another objectAtIndex:-6] == [another objectAtIndex:2]);
    assert([another objectAtIndex:-7] == [another objectAtIndex:1]);
    assert([another objectAtIndex:-8] == [another objectAtIndex:0]);
    
    
    CKLinkedList *empty = [CKLinkedList new];
    assert(empty.count == 0);
    
    int l = 0;
    for (; l < 1000; ++l) {
        assert([empty objectAtIndex:-l] == nil);
    }
    
    
    CKLinkedList *oneobject = [CKLinkedList listWithObject:@"tests"];
    assert(oneobject.count == 1);
    
    assert([oneobject objectAtIndex:0] == [oneobject objectAtIndex:-1]);
    
    for (l = 2; l < 1000; ++l) {
        assert([oneobject objectAtIndex:-l] == nil);
    }
    
    
    LNode *n = [oneobject firstNode];
    
    // this must pass
    assert(n->obj);
    assert([n->obj class]);
    // NSLog(@"%@ are passing!", n->obj);
    
    
    
}

/* Untested:
 - (void)insertObject:(id)anObject beforeNode:(LNode *)node;
 - (void)insertObject:(id)anObject afterNode:(LNode *)node;
 - (void)insertObject:(id)anObject betweenNode:(LNode *)previousNode andNode:(LNode *)nextNode;
 - (void)insertObject:(id)anObject orderedPositionByKey:(NSString *)key ascending:(BOOL)ascending;
 */

@end
