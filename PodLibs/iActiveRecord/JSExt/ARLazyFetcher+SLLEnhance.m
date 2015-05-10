//
//  ARLazyFetcher+SLLEnhance.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-3-12.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "ARLazyFetcher+SLLEnhance.h"

@implementation ARLazyFetcher(SLLEnhance)

-(id)jsFetchOne{
    NSArray *arr = [self fetchRecords];
    
    return (arr.count > 0) ? arr[0] : nil;
}

@end
