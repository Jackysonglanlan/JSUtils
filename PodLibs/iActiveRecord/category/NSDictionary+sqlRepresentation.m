//
//  NSDictionary+sqlRepresentation.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-3-4.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "NSDictionary+sqlRepresentation.h"

@implementation NSDictionary(sqlRepresentation)

- (NSString *)toSql {
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (error) {
        JS_Stub_Throw(@"CMGEChatMsg - Can't encode info to json string", @"info:%@", self);
    }
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

}

+ (id)fromSql:(NSString *)sqlData {
    id dic = [NSJSONSerialization JSONObjectWithData:[sqlData dataUsingEncoding:NSUTF8StringEncoding]
                                             options:0 error:nil];
    return dic;
}

+ (const char *)sqlType {
    return "text";
}

@end
