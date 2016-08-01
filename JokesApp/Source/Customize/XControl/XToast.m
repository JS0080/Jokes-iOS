//
//  XToast.m
//  Mandarin
//
//  Created by Michale on 1/17/15.
//  Copyright (c) 2015 Dragon. All rights reserved.
//


#import "XToast.h"
#import <QuartzCore/QuartzCore.h>

#define CURRENT_TOAST_TAG 6984678

static const CGFloat kComponentPadding = 5;

static XToastSettings *sharedSettings = nil;

@interface XToast(private)

- (XToast *) settings;
- (CGRect)_toastFrameForImageSize:(CGSize)imageSize withLocation:(XToastImageLocation)location andTextSize:(CGSize)textSize;
- (CGRect)_frameForImage:(XToastType)type inToastFrame:(CGRect)toastFrame;

@end


@implementation XToast


- (id) initWithText:(NSString *) tex{
    if (self = [super init]) {
        text = [tex copy];
    }
    
    return self;
}

- (void) show{
    [self show:XToastTypeNone];
}

- (void) show:(XToastType) type {
    
    XToastSettings *theSettings = _settings;
    
    int space = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 80 : 100;
    
    if (!theSettings) {
        theSettings = [XToastSettings getSharedSettings];
    }
    
    UIImage *image = [theSettings.images valueForKey:[NSString stringWithFormat:@"%i", type]];
    
    UIFont *font = [UIFont systemFontOfSize:theSettings.fontSize];
    //	CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(280, 60)];
    CGSize windowSize = [UIApplication sharedApplication].keyWindow.frame.size;
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(windowSize.width * 9 / 10, 150) options: NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width + kComponentPadding, textSize.height + kComponentPadding)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = font;
    label.text = text;
    label.numberOfLines = 0;
    if (theSettings.useShadow) {
        label.shadowColor = [UIColor darkGrayColor];
        label.shadowOffset = CGSizeMake(1, 1);
    }
    
    UIButton *v = [UIButton buttonWithType:UIButtonTypeCustom];
    if (image) {
        v.frame = [self _toastFrameForImageSize:image.size withLocation:[theSettings imageLocation] andTextSize:textSize];
        
        switch ([theSettings imageLocation]) {
            case XToastImageLocationLeft:
                [label setTextAlignment:NSTextAlignmentLeft];
                label.center = CGPointMake(image.size.width + kComponentPadding * 2
                                           + (v.frame.size.width - image.size.width - kComponentPadding * 2) / 2,
                                           v.frame.size.height / 2);
                break;
            case XToastImageLocationTop:
                [label setTextAlignment:NSTextAlignmentCenter];
                label.center = CGPointMake(v.frame.size.width / 2,
                                           (image.size.height + kComponentPadding * 2
                                            + (v.frame.size.height - image.size.height - kComponentPadding * 2) / 2));
                break;
            default:
                break;
        }
        
    } else {
        v.frame = CGRectMake(0, 0, textSize.width + kComponentPadding * 2, textSize.height + kComponentPadding * 2);
        label.center = CGPointMake(v.frame.size.width / 2, v.frame.size.height / 2);
    }
    CGRect lbfrm = label.frame;
    lbfrm.origin.x = ceil(lbfrm.origin.x);
    lbfrm.origin.y = ceil(lbfrm.origin.y);
    label.frame = lbfrm;
    [v addSubview:label];
    
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = [self _frameForImage:type inToastFrame:v.frame];
        [v addSubview:imageView];
    }
    
    v.backgroundColor = [UIColor colorWithRed:theSettings.bgRed green:theSettings.bgGreen blue:theSettings.bgBlue alpha:theSettings.bgAlpha];
    v.layer.cornerRadius = theSettings.cornerRadius;
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    
    CGPoint point;
    
    // Set correct orientation/location regarding device orientation
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
        {
            if (theSettings.gravity == XToastGravityTop) {
                point = CGPointMake(window.frame.size.width / 2, space);
            } else if (theSettings.gravity == XToastGravityBottom) {
                point = CGPointMake(window.frame.size.width / 2, window.frame.size.height - space);
            } else if (theSettings.gravity == XToastGravityCenter) {
                point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
            } else {
                point = theSettings.postition;
            }
            
            point = CGPointMake(point.x + theSettings.offsetLeft, point.y + theSettings.offsetTop);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown:
        {
            v.transform = CGAffineTransformMakeRotation(M_PI);
            
            float width = window.frame.size.width;
            float height = window.frame.size.height;
            
            if (theSettings.gravity == XToastGravityTop) {
                point = CGPointMake(width / 2, height - space);
            } else if (theSettings.gravity == XToastGravityBottom) {
                point = CGPointMake(width / 2, space);
            } else if (theSettings.gravity == XToastGravityCenter) {
                point = CGPointMake(width/2, height/2);
            } else {
                // TODO : handle this case
                point = theSettings.postition;
            }
            
            point = CGPointMake(point.x - theSettings.offsetLeft, point.y - theSettings.offsetTop);
            break;
        }
        case UIDeviceOrientationLandscapeLeft:
        {
            v.transform = CGAffineTransformMakeRotation(M_PI/2); //rotation in radians
            
            if (theSettings.gravity == XToastGravityTop) {
                point = CGPointMake(window.frame.size.width - space, window.frame.size.height / 2);
            } else if (theSettings.gravity == XToastGravityBottom) {
                point = CGPointMake(space,window.frame.size.height / 2);
            } else if (theSettings.gravity == XToastGravityCenter) {
                point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
            } else {
                // TODO : handle this case
                point = theSettings.postition;
            }
            
            point = CGPointMake(point.x - theSettings.offsetTop, point.y - theSettings.offsetLeft);
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            v.transform = CGAffineTransformMakeRotation(-M_PI/2);
            
            if (theSettings.gravity == XToastGravityTop) {
                point = CGPointMake(space, window.frame.size.height / 2);
            } else if (theSettings.gravity == XToastGravityBottom) {
                point = CGPointMake(window.frame.size.width - space, window.frame.size.height/2);
            } else if (theSettings.gravity == XToastGravityCenter) {
                point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
            } else {
                // TODO : handle this case
                point = theSettings.postition;
            }
            
            point = CGPointMake(point.x + theSettings.offsetTop, point.y + theSettings.offsetLeft);
            break;
        }
        default:
            break;
    }
    
    v.center = point;
    v.frame = CGRectIntegral(v.frame);
    
    NSTimer *timer1 = [NSTimer timerWithTimeInterval:((float)theSettings.duration)/1000
                                              target:self selector:@selector(hideToast:)
                                            userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
    
    v.tag = CURRENT_TOAST_TAG;
    
    UIView *currentToast = [window viewWithTag:CURRENT_TOAST_TAG];
    if (currentToast != nil) {
        [currentToast removeFromSuperview];
    }
    
    v.alpha = 0;
    [window addSubview:v];
    [UIView beginAnimations:nil context:nil];
    v.alpha = 1;
    [UIView commitAnimations];
    
    view = v;
    
    [v addTarget:self action:@selector(hideToast:) forControlEvents:UIControlEventTouchDown];
}

- (CGRect)_toastFrameForImageSize:(CGSize)imageSize withLocation:(XToastImageLocation)location andTextSize:(CGSize)textSize {
    CGRect theRect = CGRectZero;
    switch (location) {
        case XToastImageLocationLeft:
            theRect = CGRectMake(0, 0,
                                 imageSize.width + textSize.width + kComponentPadding * 3,
                                 MAX(textSize.height, imageSize.height) + kComponentPadding * 2);
            break;
        case XToastImageLocationTop:
            theRect = CGRectMake(0, 0,
                                 MAX(textSize.width, imageSize.width) + kComponentPadding * 2,
                                 imageSize.height + textSize.height + kComponentPadding * 3);
            
        default:
            break;
    }
    return theRect;
}

- (CGRect)_frameForImage:(XToastType)type inToastFrame:(CGRect)toastFrame {
    XToastSettings *theSettings = _settings;
    UIImage *image = [theSettings.images valueForKey:[NSString stringWithFormat:@"%i", type]];
    
    if (!image) return CGRectZero;
    
    CGRect imageFrame = CGRectZero;
    
    switch ([theSettings imageLocation]) {
        case XToastImageLocationLeft:
            imageFrame = CGRectMake(kComponentPadding, (toastFrame.size.height - image.size.height) / 2, image.size.width, image.size.height);
            break;
        case XToastImageLocationTop:
            imageFrame = CGRectMake((toastFrame.size.width - image.size.width) / 2, kComponentPadding, image.size.width, image.size.height);
            break;
            
        default:
            break;
    }
    
    return imageFrame;
    
}

- (void) hideToast:(NSTimer*)theTimer{
    [UIView beginAnimations:nil context:NULL];
    view.alpha = 0;
    [UIView commitAnimations];
    
    NSTimer *timer2 = [NSTimer timerWithTimeInterval:500
                                              target:self selector:@selector(hideToast:)
                                            userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
}

- (void) removeToast:(NSTimer*)theTimer{
    [view removeFromSuperview];
}


+ (XToast *) makeText:(NSString *) _text{
    XToast *toast = [[XToast alloc] initWithText:_text];
    
    return toast;
}


- (XToast *) setDuration:(NSInteger ) duration{
    [self theSettings].duration = duration;
    return self;
}

- (XToast *) setGravity:(XToastGravity) gravity
             offsetLeft:(NSInteger) left
              offsetTop:(NSInteger) top{
    [self theSettings].gravity = gravity;
    [self theSettings].offsetLeft = left;
    [self theSettings].offsetTop = top;
    return self;
}

- (XToast *) setGravity:(XToastGravity) gravity{
    [self theSettings].gravity = gravity;
    return self;
}

- (XToast *) setPostion:(CGPoint) _position{
    [self theSettings].postition = CGPointMake(_position.x, _position.y);
    
    return self;
}

- (XToast *) setFontSize:(CGFloat) fontSize{
    [self theSettings].fontSize = fontSize;
    return self;
}

- (XToast *) setUseShadow:(BOOL) useShadow{
    [self theSettings].useShadow = useShadow;
    return self;
}

- (XToast *) setCornerRadius:(CGFloat) cornerRadius{
    [self theSettings].cornerRadius = cornerRadius;
    return self;
}

- (XToast *) setBgRed:(CGFloat) bgRed{
    [self theSettings].bgRed = bgRed;
    return self;
}

- (XToast *) setBgGreen:(CGFloat) bgGreen{
    [self theSettings].bgGreen = bgGreen;
    return self;
}

- (XToast *) setBgBlue:(CGFloat) bgBlue{
    [self theSettings].bgBlue = bgBlue;
    return self;
}

- (XToast *) setBgAlpha:(CGFloat) bgAlpha{
    [self theSettings].bgAlpha = bgAlpha;
    return self;
}


-(XToastSettings *) theSettings{
    if (!_settings) {
        _settings = [[XToastSettings getSharedSettings] copy];
    }
    
    return _settings;
}

+ (void)showMessage:(NSString *)text gravity:(XToastGravity)gravity duration:(NSInteger)duration {
    
    XToast * toast = [XToast makeText:text];
    
    [toast setGravity:gravity];
    [toast setDuration:duration];
    [toast show];
}

+ (void)showMessage:(NSString *)text gravity:(XToastGravity)gravity {
    
    [self showMessage:text gravity:gravity duration:XToastDurationNormal];
}

+ (void)showMessage:(NSString *)text {
    
    [self showMessage:text gravity:XToastGravityBottom duration:XToastDurationNormal];
}

@end


@implementation XToastSettings
@synthesize offsetLeft;
@synthesize offsetTop;
@synthesize duration;
@synthesize gravity;
@synthesize postition;
@synthesize fontSize;
@synthesize useShadow;
@synthesize cornerRadius;
@synthesize bgRed;
@synthesize bgGreen;
@synthesize bgBlue;
@synthesize bgAlpha;
@synthesize images;
@synthesize imageLocation;

- (void) setImage:(UIImage *) img withLocation:(XToastImageLocation)location forType:(XToastType) type {
    if (type == XToastTypeNone) {
        // This should not be used, internal use only (to force no image)
        return;
    }
    
    if (!images) {
        images = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    if (img) {
        NSString *key = [NSString stringWithFormat:@"%i", type];
        [images setValue:img forKey:key];
    }
    
    [self setImageLocation:location];
}

- (void)setImage:(UIImage *)img forType:(XToastType)type {
    [self setImage:img withLocation:XToastImageLocationLeft forType:type];
}


+ (XToastSettings *) getSharedSettings{
    if (!sharedSettings) {
        sharedSettings = [XToastSettings new];
        sharedSettings.gravity = XToastGravityCenter;
        sharedSettings.duration = XToastDurationShort;
        sharedSettings.fontSize = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 17.0 : 24.0;
        sharedSettings.useShadow = YES;
        sharedSettings.cornerRadius = 5.0;
        sharedSettings.bgRed = 0;
        sharedSettings.bgGreen = 0;
        sharedSettings.bgBlue = 0;
        sharedSettings.bgAlpha = 0.7;
        sharedSettings.offsetLeft = 0;
        sharedSettings.offsetTop = 0;
    }
    
    return sharedSettings;
    
}

- (id) copyWithZone:(NSZone *)zone{
    XToastSettings *copy = [XToastSettings new];
    copy.gravity = self.gravity;
    copy.duration = self.duration;
    copy.postition = self.postition;
    copy.fontSize = self.fontSize;
    copy.useShadow = self.useShadow;
    copy.cornerRadius = self.cornerRadius;
    copy.bgRed = self.bgRed;
    copy.bgGreen = self.bgGreen;
    copy.bgBlue = self.bgBlue;
    copy.bgAlpha = self.bgAlpha;
    copy.offsetLeft = self.offsetLeft;
    copy.offsetTop = self.offsetTop;
    
    NSArray *keys = [self.images allKeys];
    
    for (NSString *key in keys){
        [copy setImage:[images valueForKey:key] forType:[key intValue]];
    }
    
    [copy setImageLocation:imageLocation];
    
    return copy;
}

@end
