//
//  RangeCollection.m
//
//  Created by jacky.song on 12-8-15.
//  Copyright (c) 2012 Symbio. All rights reserved.
//

#import "RangeCollection.h"

@implementation RangeCollection{
  NSMutableDictionary *dic;
  NSUInteger maxRangeLength;
}

- (id)init{
    self = [super init];
    if (self) {
        dic = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc{
    [dic release];
    dic = nil;
    [super dealloc];
}

-(NSString*)description{
    return [dic description];
}

-(void)add:(NSRange)newRange{
    maxRangeLength = MAX(maxRangeLength, newRange.length);
    
    BOOL isWholeIn = NO;
    
    // head
    NSUInteger readyToMergeStart = newRange.location;
    NSInteger newLoc = 0;
    for (int i=newRange.location; i>=0; i--) {
        NSValue *value = [dic objectForKey:iObject(i)];
        // find the one just before the newRange
        if (value) {
            NSRange range = rangeValue(value);
            // if the location is in between, notice for the head, one larger is also "between", so we -1
            if (JS_IsBetweenRange(newRange.location-1, range)) {
                readyToMergeStart = i;
                newLoc = range.location;
                // check if the length also in between
                if (JS_IsBetweenRange(newRange.length, range)) {
                    isWholeIn = YES;
                }
                break;
            }
        }
        // if not found, newLoc is the new value
        else{
            newLoc = newRange.location;
        }
    }
    
    if (isWholeIn) return;
    
    // tail
    NSUInteger readyToMergeEnd = newRange.length;
    NSInteger newLen = 0;
    for (int i=newRange.location; i<=maxRangeLength; i++) {
        NSValue *value = [dic objectForKey:iObject(i)];
        // find the one just after the newRange
        if (value) {
            NSRange range = rangeValue(value);
            // if the length is in between, notice for the tail one smaller is also "between", so we +1
            if (JS_IsBetweenRange(newRange.length+1, range)) {
                newLen = range.length;
                readyToMergeEnd = i;
                break;
            }
        }
        // if not found, newLen is the new value
        else{
            newLen = newRange.length;
        }
    }
    
    //    NSLog(@"%d",newLen);
    
    // remove the overlapped ranges
    for (int i=readyToMergeStart; i<=readyToMergeEnd; i++) {
        [dic removeObjectForKey:iObject(i)];
    }
    
    // add new
    [dic setObject:rangeObject(NSMakeRange(newLoc, newLen)) forKey:iObject(newLoc)];
    
//    [dic log];
}

-(NSRange)getByLocation:(NSUInteger)location{
    if ([self containsLocation:location]) {
        return [(NSValue*)[dic objectForKey:iObject(location)] rangeValue];
    }
    return NSMakeRange(0, 0);
}

-(void)remove:(NSUInteger)location{
    [dic removeObjectForKey:iObject(location)];
}

-(void)removeAll{
    [dic removeAllObjects];
}

-(BOOL)containsLocation:(NSUInteger)location{
    return [dic objectForKey:iObject(location)] != nil;
}

-(BOOL)containsLocation:(NSUInteger)location length:(NSUInteger)length{
    for (int i=location; i>=0; i--) {
        NSValue *value = [dic objectForKey:iObject(i)];
        // find the one just before the newRange
        if (value) {
            NSRange range = rangeValue(value);
            // if the location is in between
            if (JS_IsBetweenRange(location, range) && JS_IsBetweenRange(length, range)) {
                return YES;
            }
        }
    }
    return NO;
}

@end