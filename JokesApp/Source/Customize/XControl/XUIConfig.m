//
//  XUIConfig.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "XUIConfig.h"

@interface XUIConfig ()

@property (nonatomic, assign) XDeviceModel deviceModel;
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) BOOL phone;
@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) CGFloat ratev;

@end

@implementation XUIConfig

+ (XUIConfig *) sharedInstance {
    
    static XUIConfig * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[XUIConfig alloc] init];
    });
    
    return instance;
}

- (instancetype) init {
    
    self = [super init];
    if (self)
        [self setup];
    
    return self;
}

- (void) setup {
    
    self.screenSize = [[UIScreen mainScreen] bounds].size;
    self.phone = [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad;
    
    if (self.phone) {
        
        if (_screenSize.width == 736.0f || _screenSize.height == 736.0f)
            self.deviceModel = XDeviceModelIPhone6p;
        else if (_screenSize.width == 667.0f || _screenSize.height == 667.0f)
            self.deviceModel = XDeviceModelIPhone6;
        else if (_screenSize.width == 568.0f || _screenSize.height == 568.0f)
            self.deviceModel = XDeviceModelIPhone5;
        else
            self.deviceModel = XDeviceModelIPhone4;
    }
    else {
        
        self.deviceModel = XDeviceModelIPad;
    }
    
    if (self.phone) {
        
        self.rate = MIN(_screenSize.width, _screenSize.height) / 320.0f;
        self.ratev = self.rate;
    }
    else {
        
        self.rate = 2.0f;
        self.ratev = 1.8f;
    }
}

+ (XDeviceModel) deviceModel {
    
    return [XUIConfig sharedInstance].deviceModel;
}

+ (CGSize) screenSize {
    
    return [XUIConfig sharedInstance].screenSize;
}

+ (BOOL) isPad {
    
    return ![XUIConfig sharedInstance].phone;
}

+ (BOOL) isPhone {
    
    return [XUIConfig sharedInstance].phone;
}

+ (BOOL) isPhone4 {
    
    return [XUIConfig sharedInstance].deviceModel == XDeviceModelIPhone4;
}

+ (BOOL) isPortrait {
    
    return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}

+ (BOOL) isLandscape {
    
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
}

+ (CGFloat) resizeValue:(CGFloat)phone4 {
    
    return (int) (phone4 * [XUIConfig sharedInstance].rate);
}

+ (CGFloat) resizeValueV:(CGFloat)phone4 {
    
    return (int) (phone4 * [XUIConfig sharedInstance].ratev);
}

+ (CGFloat) resizeValue:(CGFloat)phone4 pad:(CGFloat)pad {
    
    XUIConfig * config = [XUIConfig sharedInstance];
    
    if (!config.phone)
        return pad;
    
    return (int) (phone4 * config.rate);
}

@end

CGRect calcAlignFrame(CGRect frame, CGSize size, XAlign align)
{
    
    CGRect alignFrame;
    
    if (is_align_left(align))
        alignFrame.origin.x = frame.origin.x;
    else if (is_align_right(align))
        alignFrame.origin.x = CGRectGetMaxX(frame) - size.width;
    else
        alignFrame.origin.x = frame.origin.x + (frame.size.width - size.width) / 2;
    
    if (is_align_top(align))
        alignFrame.origin.y = frame.origin.y;
    else if (is_align_bottom(align))
        alignFrame.origin.y = CGRectGetMaxY(frame) - size.height;
    else
        alignFrame.origin.y = frame.origin.y + (frame.size.height - size.height) / 2;
    
    alignFrame.size.width = size.width;
    alignFrame.size.height = size.height;
    
    return alignFrame;
}
