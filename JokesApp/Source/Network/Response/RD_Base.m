//
//  RD_Base.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "RD_Base.h"

@implementation RD_Base

- (instancetype) init {
    
    self = [super init];
    if (self)
        [self setup];
    
    return self;
}

- (instancetype) initFromJson:(id)json {
    
    self = [self init];
    if (self) {
        
        [self setup];
        
        _parsed = [self fromJson:json];
    }
    
    return self;
}

- (void) setup {
    
    _parsed = NO;
    _json = nil;
}

- (BOOL) fromJson:(id)json {
    
    if (!json || [json isKindOfClass:[NSNull class]])
        return NO;
    
    _json = json;
    
    return YES;
}

- (NSString *) toJson {
    
    if (self.json)
        return [self.json getJSONString];
    
    return @"";
}

- (NSArray *) arrayFromJson:(id)json key:(NSString *)key rdClass:(Class)rdClass {
    
    NSMutableArray * arrRd = [NSMutableArray array];
    NSArray * arrJson = [json optJSONArray:key];
    
    if (arrJson && arrJson.count > 0) {
        
        for (id item in arrJson) {
            
            id rdItem = [[rdClass alloc] init];
            if ([rdItem fromJson:item])
                [arrRd addObject:rdItem];
        }
    }
    
    return [NSArray arrayWithArray:arrRd];
}

@end
