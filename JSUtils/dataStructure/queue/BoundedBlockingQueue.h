//
//  BlockingQueue.h
//  ThreadTest
//
//  Created by BIBHAS BHATTACHARYA on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoundedBlockingQueue : NSObject

- (BoundedBlockingQueue*) initWithSize: (int) size;
- (void) put: (id) data;
- (id) take: (int) timeout;
- (BOOL) isInQueue: (id) obj;

@end
