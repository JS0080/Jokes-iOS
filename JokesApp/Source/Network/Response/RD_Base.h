//
//  RD_Base.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+JSON.h"

@interface RD_Base : NSObject

@property (nonatomic, retain) id        json;
@property (nonatomic, assign) BOOL      parsed;

- (instancetype) initFromJson:(id)json;

- (void) setup;
- (BOOL) fromJson:(id)json;
- (NSString *) toJson;

- (NSArray *) arrayFromJson:(id)json key:(NSString *)key rdClass:(Class)rdClass;

@end
