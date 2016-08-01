//
//  AppSettingBase.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettingBase : NSObject

- (void) setup;
- (void) saveSetting;
- (void) loadSetting;

- (NSInteger) integerForKey:(NSString *)key defVal:(NSInteger)defVal;
- (void) setInteger:(NSInteger)value forKey:(NSString *)key;

- (BOOL) boolForKey:(NSString *)key defVal:(BOOL)defVal;
- (void) setBool:(BOOL)value forKey:(NSString *)key;

- (float) floatForKey:(NSString *)key defVal:(float)defVal;
- (void) setFloat:(float)value forKey:(NSString *)key;

- (id) objectForKey:(NSString *)key defVal:(id)defVal;
- (void) setObject:(id)value forKey:(NSString *)key;

- (NSString *) stringForKey:(NSString *)key defVal:(NSString *)defVal;
- (void) setString:(NSString *)value forKey:(NSString *)key;

@end
