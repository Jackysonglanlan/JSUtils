//
//  JSPipeLineUnit.h
//  JSUtils
//
//  Created by jackysong on 14-12-3.
//  Copyright (c) 2014年 Jacky.Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSPipeLineContext;

@protocol JSPipeLineUnit <NSObject>

-(void)process:(id)income context:(JSPipeLineContext*)context;

@end
