//
//  NSDictionary+JSON.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSON)

+ (id) getJSONObjectFromString:(NSString *)strJSON;
+ (NSString *) getJSONStringFromObject:(id)object;

- (NSString *) getJSONString;

- (id) getJSONObject:(NSString *)key;

- (double) getDouble:(NSString *)key;
- (NSString *) getString:(NSString *)key;

- (int) optInt:(NSString *)key defaultValue:(int)defaultValue;
- (BOOL) optBool:(NSString *)key defaultValue:(BOOL)defaultValue;
- (double) optDouble:(NSString *)key defaultValue:(double)defaultValue;
- (NSString *) optString:(NSString *)key defaultValue:(NSString *)defaultValue;
- (NSArray *) optJSONArray:(NSString *)key;

@end
