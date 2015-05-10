//
//  NSNumber+sqlRepresentation.m
//  iActiveRecord
//
//  Created by Alex Denisov on 17.01.12.
//  Copyright (c) 2012 CoreInvader. All rights reserved.
//

#import "NSNumber+sqlRepresentation.h"

@implementation NSNumber (sqlRepresentation)

- (NSString *)toSql {
    return [NSString stringWithFormat:@"%@", self];
}

+ (const char *)sqlType {
    return "integer";
}

+ (id)fromSql:(NSString *)sqlData{
    return [NSNumber numberWithUnsignedLongLong:[sqlData longLongValue]];
}

@end
