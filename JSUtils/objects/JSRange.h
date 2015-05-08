//
//  JSRange.h
//  TianTian
//
//  Created by Song Lanlan on 13-11-23.
//  Copyright (c) 2013年 tiantian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSRange : NSObject

@property(nonatomic,assign) long long from;
@property(nonatomic,assign) long long to;

+(instancetype)rangeFrom:(long long)from to:(long long)to;

-(id)initWithFrom:(long long)from to:(long long)to;

-(BOOL)isInRange:(long long)value;

@end
