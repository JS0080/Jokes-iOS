//
//  AppSettingBase.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "AppSettingBase.h"

@implementation AppSettingBase

- (instancetype) init {
    
    self = [super init];
    if (self)
        [self setup];
    
    return self;
}

- (void) setup {
    
    [self loadSetting];
}

- (void) loadSetting {
    
}

- (void) saveSetting {
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger) integerForKey:(NSString *)key defVal:(NSInteger)defVal {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
        return [[NSUserDefaults standardUserDefaults] integerForKey:key];
    
    return defVal;
}

- (void) setInteger:(NSInteger)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    [self saveSetting];
}

- (BOOL) boolForKey:(NSString *)key defVal:(BOOL)defVal {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
        return [[NSUserDefaults standardUserDefaults] boolForKey:key];
    
    return defVal;
}

- (void) setBool:(BOOL)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    [self saveSetting];
}

- (float) floatForKey:(NSString *)key defVal:(float)defVal {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
        return [[NSUserDefaults standardUserDefaults] floatForKey:key];
    
    return defVal;
}

- (void) setFloat:(float)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key];
    [self saveSetting];
}

- (id) objectForKey:(NSString *)key defVal:(id)defVal {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    return defVal;
}

- (void) setObject:(id)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [self saveSetting];
}

- (NSString *) stringForKey:(NSString *)key defVal:(NSString *)defVal {
    
    return [self objectForKey:key defVal:defVal];
}

- (void) setString:(NSString *)value forKey:(NSString *)key {
    
    [self setObject:value forKey:key];
    [self saveSetting];
}

@end
