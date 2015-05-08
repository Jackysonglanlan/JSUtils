//
//  UnboundedBlockingQueue.h
//  ThreadTest
//
//  Created by BIBHAS BHATTACHARYA on 5/21/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnboundedBlockingQueue : NSObject

- (UnboundedBlockingQueue*) init;
- (void) put: (id) data;
- (id) take: (int) timeout;

@end
