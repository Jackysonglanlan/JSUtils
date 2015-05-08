//
//  RangeCollection.h
//
//  Created by jacky.song on 12-8-15.
//  Copyright (c) 2012 Symbio. All rights reserved.
//

#import <Foundation/Foundation.h>


// This class can merge range automantically when add new range. So there would be no interaction range.
@interface RangeCollection : NSObject

// Merge range automantically, which means:
// if there are {0,3} {7,8} in the collection, then you add {4,6} will cause the collection
// only left one element: {0,8}
// i.e. {0,3} {7,8} + {4,6} => {0,8}
-(void)add:(NSRange)range;

// return {0,0} if not found.
-(NSRange)getByLocation:(NSUInteger)location;

-(void)remove:(NSUInteger)location;

-(void)removeAll;

-(BOOL)containsLocation:(NSUInteger)location;

-(BOOL)containsLocation:(NSUInteger)location length:(NSUInteger)length;

@end
