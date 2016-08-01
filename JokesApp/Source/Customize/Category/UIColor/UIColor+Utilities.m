//
//  UIColor+Utilities.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "UIColor+Utilities.h"

@implementation UIColor (Utilities)

#pragma mark - Utilities

- (UIColor *) desaturatedColorToPercentSaturation:(CGFloat)percent {
    
    CGFloat h, s, b, a;
    
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    
    return [UIColor colorWithHue:h saturation:s * percent brightness:b alpha:a];
}

- (UIColor *) lightenColorWithValue:(CGFloat)value {
    
    NSUInteger totalComponents = CGColorGetNumberOfComponents(self.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(self.CGColor);
    CGFloat newComponents[4];
    
    if (isGreyscale) {
        
        newComponents[0] = oldComponents[0] + value > 1.0f ? 1.0f : oldComponents[0] + value;
        newComponents[1] = oldComponents[0] + value > 1.0f ? 1.0f : oldComponents[0] + value;
        newComponents[2] = oldComponents[0] + value > 1.0f ? 1.0f : oldComponents[0] + value;
        newComponents[3] = oldComponents[1];
    }
    else {
        
        newComponents[0] = oldComponents[0] + value > 1.0f ? 1.0f : oldComponents[0] + value;
        newComponents[1] = oldComponents[1] + value > 1.0f ? 1.0f : oldComponents[1] + value;
        newComponents[2] = oldComponents[2] + value > 1.0f ? 1.0f : oldComponents[2] + value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
}

- (UIColor *) darkenColorWithValue:(CGFloat)value {
    
    NSUInteger totalComponents = CGColorGetNumberOfComponents(self.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *oldComponents = (CGFloat *)CGColorGetComponents(self.CGColor);
    CGFloat newComponents[4];
    
    if(isGreyscale) {
        
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[2] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[3] = oldComponents[1];
    }
    else {
        
        newComponents[0] = oldComponents[0] - value < 0.0f ? 0.0f : oldComponents[0] - value;
        newComponents[1] = oldComponents[1] - value < 0.0f ? 0.0f : oldComponents[1] - value;
        newComponents[2] = oldComponents[2] - value < 0.0f ? 0.0f : oldComponents[2] - value;
        newComponents[3] = oldComponents[3];
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
    return retColor;
}

- (BOOL) isLightColor {
    
    NSUInteger totalComponents = CGColorGetNumberOfComponents(self.CGColor);
    BOOL isGreyscale = (totalComponents == 2) ? YES : NO;
    
    CGFloat *components = (CGFloat *)CGColorGetComponents(self.CGColor);
    CGFloat sum;
    
    if(isGreyscale) {
        
        sum = components[0];
    }
    else {
        
        sum = (components[0] + components[1] + components[2]) / 3.0f;
    }
    
    return (sum >= 0.75f);
}

@end