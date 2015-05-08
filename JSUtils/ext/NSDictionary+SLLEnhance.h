//
//  NSDictionary+SLLEnhance.h
//  template_ios_project
//
//  Created by Lanlan Song on 12-5-17.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(SLLEnhance)

+(NSDictionary*)jsLoadPlistFileData:(NSString*)fileName;

- (id)jsKeyForValue:(id)value;

@end


@interface NSMutableDictionary(SLLEnhance)

-(void)jsSetObject:(id)object forKeyPath:(NSString*)keyPath;

@end
