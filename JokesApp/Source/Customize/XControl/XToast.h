//
//  XToast.h
//  Mandarin
//
//  Created by Michale on 1/17/15.
//  Copyright (c) 2015 Dragon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum XToastGravity {
    XToastGravityTop = 1000001,
    XToastGravityBottom,
    XToastGravityCenter
}XToastGravity;

typedef enum XToastDuration {
    XToastDurationLong = 10000,
    XToastDurationShort = 1000,
    XToastDurationNormal = 3000
}XToastDuration;

typedef enum XToastType {
    XToastTypeInfo = -100000,
    XToastTypeNotice,
    XToastTypeWarning,
    XToastTypeError,
    XToastTypeNone // For internal use only (to force no image)
}XToastType;

typedef enum {
    XToastImageLocationTop,
    XToastImageLocationLeft
} XToastImageLocation;


@class XToastSettings;

@interface XToast : NSObject {
    XToastSettings *_settings;
    
    NSTimer *timer;
    
    UIView *view;
    NSString *text;
}

- (void) show;
- (void) show:(XToastType) type;
- (XToast *) setDuration:(NSInteger ) duration;
- (XToast *) setGravity:(XToastGravity) gravity
             offsetLeft:(NSInteger) left
              offsetTop:(NSInteger) top;
- (XToast *) setGravity:(XToastGravity) gravity;
- (XToast *) setPostion:(CGPoint) position;
- (XToast *) setFontSize:(CGFloat) fontSize;
- (XToast *) setUseShadow:(BOOL) useShadow;
- (XToast *) setCornerRadius:(CGFloat) cornerRadius;
- (XToast *) setBgRed:(CGFloat) bgRed;
- (XToast *) setBgGreen:(CGFloat) bgGreen;
- (XToast *) setBgBlue:(CGFloat) bgBlue;
- (XToast *) setBgAlpha:(CGFloat) bgAlpha;

+ (XToast *) makeText:(NSString *) text;

-(XToastSettings *) theSettings;

+ (void) showMessage:(NSString *)text gravity:(XToastGravity)gravity duration:(NSInteger)duration;
+ (void) showMessage:(NSString *)text gravity:(XToastGravity)gravity;
+ (void) showMessage:(NSString *)text;

@end



@interface XToastSettings : NSObject<NSCopying>{
    NSInteger duration;
    XToastGravity gravity;
    CGPoint postition;
    XToastType toastType;
    CGFloat fontSize;
    BOOL useShadow;
    CGFloat cornerRadius;
    CGFloat bgRed;
    CGFloat bgGreen;
    CGFloat bgBlue;
    CGFloat bgAlpha;
    NSInteger offsetLeft;
    NSInteger offsetTop;
    
    NSDictionary *images;
    
    BOOL positionIsSet;
}


@property(assign) NSInteger duration;
@property(assign) XToastGravity gravity;
@property(assign) CGPoint postition;
@property(assign) CGFloat fontSize;
@property(assign) BOOL useShadow;
@property(assign) CGFloat cornerRadius;
@property(assign) CGFloat bgRed;
@property(assign) CGFloat bgGreen;
@property(assign) CGFloat bgBlue;
@property(assign) CGFloat bgAlpha;
@property(assign) NSInteger offsetLeft;
@property(assign) NSInteger offsetTop;
@property(readonly) NSDictionary *images;
@property(assign) XToastImageLocation imageLocation;


- (void) setImage:(UIImage *)img forType:(XToastType) type;
- (void) setImage:(UIImage *)img withLocation:(XToastImageLocation)location forType:(XToastType)type;
+ (XToastSettings *) getSharedSettings;

@end