//
//  CLLocation+sqlRepresentation.m
//  CMGESocialSDK
//
//  Created by jackysong on 14-3-11.
//  Copyright (c) 2014年 jackysong. All rights reserved.
//

#import "CLLocation+sqlRepresentation.h"

@implementation CLLocation(sqlRepresentation)

- (NSString *)toSql {
    // format: {lan, long}

    return [NSString stringWithFormat:@"{%f,%f}", self.coordinate.latitude, self.coordinate.longitude];
}

+ (id)fromSql:(NSString *)sqlData {
    if (sqlData.length == 0) {
        return [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease];
    }
    
    // format: {lan, long}
    
    NSArray *tmp = [[sqlData substring:1 length:sqlData.length-1] componentsSeparatedByString:@","];
    
    return [[[CLLocation alloc] initWithLatitude:[tmp[0] doubleValue]
                                       longitude:[tmp[1] doubleValue]] autorelease];
}

+ (const char *)sqlType {
    return "text";
}

@end
