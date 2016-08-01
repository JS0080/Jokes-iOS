//
//  UIImage+Helper.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize tintColor:(UIColor *)tintColor;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *)image;
+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *)buffer withWidth:(int)width withHeight:(int)height;
+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef)image;
+ (UIImage *) emptyImage:(CGSize)szSize;

@end
