//
//  UIColor+Utilities.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RGBA_F(r, g, b, a)      [UIColor colorWithRed:(r) green:(g) blue:(b) alpha:(a)]
#define RGBA_I(r, g, b, a)      RGBA_F((r) / 255.0f, (g) / 255.0f, (b) / 255.0f, (a) / 255.0f)
#define RGB_I(r, g, b)          RGBA_F((r) / 255.0f, (g) / 255.0f, (b) / 255.0f, 1.0f)

@interface UIColor (Utilities)

#pragma mark - Utilities

- (UIColor *) desaturatedColorToPercentSaturation:(CGFloat)percent;
- (UIColor *) lightenColorWithValue:(CGFloat)value;
- (UIColor *) darkenColorWithValue:(CGFloat)value;

- (BOOL)      isLightColor;

@end
