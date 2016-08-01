//
//  NSString+Utilities.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (BOOL) isEmpty {
    
    if (self == nil)
        return YES;
    
    if (self.length == 0)
        return YES;
    
    return NO;
}

- (BOOL) isTrimEmpty {
    
    if (self == nil)
        return YES;
    
    NSString * trim = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (trim.length == 0)
        return YES;
    
    return NO;
}

- (float) parseFloatAt:(int)pos len:(int)len {
    
    @try {
        
        return [[self substringWithRange:NSMakeRange(pos, len)] intValue];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return 0.0;
}

- (int) parseAPAt:(int)pos len:(int)len {
    
    @try {
        
        NSString * str = [[self substringWithRange:NSMakeRange(pos, len)] lowercaseString];
        
        if ([str isEqual:@"pm"])
            return 1;
        else
            return 0;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return 0;
}

- (float) parsePrice {
    
    @try {
        
        if ([self hasPrefix:@"$"])
            return [[self substringFromIndex:1] floatValue];
        return [self floatValue];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    return 0;
}

@end
