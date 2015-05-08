//
//  NSDictionary+SLLEnhance.m
//  template_ios_project
//
//  Created by Lanlan Song on 12-5-17.
//  Copyright (c) 2012 Cybercom. All rights reserved.
//

#import "NSDictionary+SLLEnhance.h"

@implementation NSDictionary(SLLEnhance)

+(NSDictionary*)jsLoadPlistFileData:(NSString*)fileName{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    return [NSDictionary  dictionaryWithContentsOfFile:path];
}

- (id)jsKeyForValue:(id)value{
    for (id key in [self allKeys]) {
        if ([self objectForKey:key] == value) {
            return key;
        }
    }
    return nil;
}

- (id)nonNullObjectForKey:(NSString *)key {
    id objct = [self objectForKey:key];
    if (![objct isKindOfClass:[NSNull class]]) {
        return objct;
    }
    return nil;
}
@end


@implementation NSMutableDictionary(SLLEnhance)

-(void)jsSetObject:(id)object forKeyPath:(NSString*)keyPath{
    NSArray *tmp = [keyPath componentsSeparatedByString:@"."];
    NSString *realKey = [tmp lastObject];
    NSMutableDictionary *dic = self;
    for (NSString *key in tmp) {
        id value = dic[key];
        
        // no this key or it's a dictionary
        if (!value || [[value class] isSubclassOfClass:NSDictionary.class]) {
            if (!value) value = @{};
            // add or change to mutable
            value = [NSMutableDictionary dictionaryWithDictionary:value];
            dic[key] = value;
        }
        
        if (key == realKey) {
            [dic setObject:object forKey:realKey];
        }
        else{
            // replace
            dic = value;
            // go to inner layer
        }
    }
}

@end