//
//  JSObjUtils.h
//
//  Created by jackysong on 10-11-22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JSNSObjectUtils : NSObject {
  
}

+(NSValue *) jsStructToObj:(const void *)structData objCType:(const char *)type;

+(void) jsStructFromObj:(NSValue *)wrapper value:(void *)structValue;

@end
