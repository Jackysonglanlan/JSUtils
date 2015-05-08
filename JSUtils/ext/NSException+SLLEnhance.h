//
//  NSException+SLLEnhance.h
//  template_ios_project
//
//  Created by Lanlan Song on 12-3-21.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSException(SLLEnhance)

- (void)generateStackTraceForException;

@end
