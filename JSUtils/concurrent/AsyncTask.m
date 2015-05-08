//
//  AsyncTask.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-4-6.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import "AsyncTask.h"
#import "JSMacros.h"

@implementation AsyncTask

static char *QUEUE_ID = "_jackysong_AsyncTask_inner_queue";

- (id)init{
  if (self = [super init]) {
    dispatcher = [JSGCDDispatcher sharedInstance];
    queue = dispatch_queue_create(QUEUE_ID, DISPATCH_QUEUE_SERIAL);
    group = dispatch_group_create();
  }
  return self;
}

- (void)dealloc{
  JS_releaseSafely(context);
  dispatch_release(queue);
  dispatch_release(group);
  [super dealloc];
}

#pragma mark - public

- (void)execute:(id)ctx{
  context = [ctx retain];

  // async execute
  dispatch_group_async(group, queue, ^{
    id result = [[self doInBackground:context] retain];
    [context release];
    context = result;
  });
  
  // when finished
  dispatch_group_notify(group, queue, ^{
    // dispatch in main thread !
    [dispatcher dispatchAsyncOnMainThread:^{
      [self onPostExecuteInMainThread:context];
    }];
  });
}

- (void)publishProgress:(id)progressContext{
  // dispatch in main thread !
  [dispatcher dispatchSyncOnMainThread:^{
    [self onProcessUpdateInMainThread:progressContext];
  }];
}

#pragma mark - subclass overridden

- (id)doInBackground:(id)context{
  return nil;
}

- (void)onProcessUpdateInMainThread:(id)progressContext{
  
}

- (void)onPostExecuteInMainThread:(id)result{
  
}

@end
