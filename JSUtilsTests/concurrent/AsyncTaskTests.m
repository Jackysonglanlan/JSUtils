//
//  AsyncTaskTests.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-4-6.
//  Copyright (c) 2012年 Cybercom. All rights reserved.
//
#import "AbstractTests.h"

#import "AsyncTask.h"

@interface FooAsyncTask : AsyncTask @end
@implementation FooAsyncTask

- (void)dealloc{
  // release properties
  // ...
  [super dealloc];
}

- (id)doInBackground:(id)context{
  NSLog([NSThread isMainThread] ? @"doInBackground main thread": @"doInBackground other thread");
  
  [self publishProgress:iObject(123)];
  
  return iObject(intValue(context)+100);
}

- (void)onProcessUpdateInMainThread:(id)progressContext{
  NSLog([NSThread isMainThread] ? @"onProcessUpdateInMainThread main thread": @"onProcessUpdateInMainThread other thread");
  NSLog(@"%@",progressContext);
}

- (void)onPostExecuteInMainThread:(id)result{
  NSLog([NSThread isMainThread] ? @"onPostExecuteInMainThread main thread": @"onPostExecuteInMainThread other thread");
  NSLog(@"%@",result);
}

@end



@interface AsyncTaskTests : AbstractTests @end

@implementation AsyncTaskTests{
  FooAsyncTask *task;
}

- (void)before{
  task = [[FooAsyncTask alloc] init];
}

- (void)after{
  JS_releaseSafely(task);
}

- (void)testExecution{
  [task execute:iObject(100)];
}

@end
