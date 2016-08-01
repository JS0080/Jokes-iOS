//
//  NSDictionary+JSON.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

+ (id) getJSONObjectFromString:(NSString *)strJSON {
    
    NSError * error;
    
    if (!strJSON)
        return nil;
    
    return [NSJSONSerialization JSONObjectWithData:[strJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
}

+ (NSString *) getJSONStringFromObject:(id)object {
    
    NSError * error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                        options:0
                                                          error:&error];
    
    if (!jsonData) return @"";
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (id) getJSONObject:(NSString *)key {
    
    return [self valueForKey:key];
}

- (double) getDouble:(NSString *)key {
    
    id value = [self getJSONObject:key];
    
    if (value == nil)
        return 0.0;
    
    if ([value isKindOfClass:[NSNumber class]])
        return [value doubleValue];
    
    if ([value isKindOfClass:[NSString class]])
        return [((NSString *) value) doubleValue];
    
    return 0.0;
}

- (NSString *) getString:(NSString *)key {
    
    id value = [self getJSONObject:key];
    
    if (value == nil)
        return nil;
    
    if ([value isKindOfClass:[NSString class]])
        return value;
    
    if ([value isKindOfClass:[NSNumber class]])
        return [value stringValue];
    
    return nil;
}

- (NSString *) getJSONString {
    
    return [NSDictionary getJSONStringFromObject:self];
}

- (int) optInt:(NSString *)key defaultValue:(int)defaultValue {
    
    id value = [self getJSONObject:key];
    
    if (value == nil)
        return defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
        return [value intValue];
    
    return defaultValue;
}

- (BOOL) optBool:(NSString *)key defaultValue:(BOOL)defaultValue {
    
    id value = [self getJSONObject:key];
    
    if (value == nil)
        return defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
        return [value boolValue];
    
    return defaultValue;
}

- (double) optDouble:(NSString *)key defaultValue:(double)defaultValue {
    
    id value = [self getJSONObject:key];
    
    if (value == nil)
        return defaultValue;
    
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]])
        return [value doubleValue];
    
    return defaultValue;
}

- (NSString *) optString:(NSString *)key defaultValue:(NSString *)defaultValue {
    
    NSString * value = [self getString:key];
    
    if (value)
        return value;
    
    return defaultValue;
}

- (NSArray *)optJSONArray:(NSString *)key {
    
    id arr = [self valueForKey:key];
    
    if (!arr)
        return nil;
    
    if ([arr isKindOfClass:[NSArray class]])
        return arr;
    
    return nil;
}

@end
