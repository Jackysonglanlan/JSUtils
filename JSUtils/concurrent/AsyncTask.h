//
//  AsyncTask.h
//  template_ios_project
//
//  Created by Lanlan Song on 12-4-6.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSGCDDispatcher.h"

/* 
 * Simulation the AsyncTask in Android, pretty handy for the simple background tasks that involves 
 * UI modification.
 */ 
@interface AsyncTask : NSObject{
  @private
  JSGCDDispatcher *dispatcher;
  dispatch_queue_t queue;
  dispatch_group_t group;
  
  id context;
}

#pragma mark - public

- (void)execute:(id)context;

- (void)publishProgress:(id)progressContext;

#pragma mark - subclass overridden methods

// Where you do your task asyncly
- (id)doInBackground:(id)context;

// Invoked after you send publishProgress: message.
// This method is executed in main thread which means you can update UI there.
- (void)onProcessUpdateInMainThread:(id)progressContext;

// Callback when your async task is done.
// This method is executed in main thread which means you can update UI there.
- (void)onPostExecuteInMainThread:(id)result;

@end
