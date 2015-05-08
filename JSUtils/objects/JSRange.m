//
//  JSRange.m
//  TianTian
//
//  Created by Song Lanlan on 13-11-23.
//  Copyright (c) 2013年 tiantian. All rights reserved.
//

#import "JSRange.h"

@implementation JSRange
@synthesize from,to;

+(instancetype)rangeFrom:(long long)from to:(long long)to{
  return [[[JSRange alloc] initWithFrom:from to:to] autorelease];
}

- (id)initWithFrom:(long long)f to:(long long)t{
  self = [super init];
  if (self) {
    from = f;
    to = t;
  }
  return self;
}

-(NSString*)description{
  return [NSString stringWithFormat:@"{%lld,%lld}",from,to];
}

-(BOOL)isInRange:(long long)value{
  return from <= value && value <= to;
}

@end
