//
//  XUIConfig.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XAlign) {
    
    XAlignLeft            = 0x01,
    XAlignRight           = 0x02,
    XAlignHCenter         = 0x04,
    XAlignTop             = 0x08,
    XAlignBottom          = 0x10,
    XAlignVCenter         = 0x20,
    XAlignNotWithText     = 0x40,
    XAlignLeftTop         = XAlignLeft | XAlignTop,
    XAlignLeftCenter      = XAlignLeft | XAlignVCenter,
    XAlignLeftBottom      = XAlignLeft | XAlignBottom,
    XAlignCenterTop       = XAlignHCenter | XAlignTop,
    XAlignCenter          = XAlignHCenter | XAlignVCenter,
    XAlignCenterBottom    = XAlignHCenter | XAlignBottom,
    XAlignRightTop        = XAlignRight | XAlignTop,
    XAlignRightCenter     = XAlignRight | XAlignVCenter,
    XAlignRightBottom     = XAlignRight | XAlignBottom,
};

typedef NS_ENUM(NSUInteger, XDeviceModel) {
    
    XDeviceModelIPad,
    XDeviceModelIPhone4,
    XDeviceModelIPhone5,
    XDeviceModelIPhone6,
    XDeviceModelIPhone6p,
};

@interface XUIConfig : NSObject

+ (XDeviceModel) deviceModel;
+ (CGSize) screenSize;

+ (BOOL) isPortrait;
+ (BOOL) isLandscape;
+ (BOOL) isPhone;
+ (BOOL) isPhone4;
+ (BOOL) isPad;

+ (CGFloat) resizeValue:(CGFloat)phone4 pad:(CGFloat)pad;
+ (CGFloat) resizeValue:(CGFloat)phone4;
+ (CGFloat) resizeValueV:(CGFloat)phone4;

@end

#define shared_application                                  ([UIApplication sharedApplication])

#define is_portrait                                         [XUIConfig isPortrait]
#define is_landscape                                        [XUIConfig isLandscape]

#define is_iphone                                           [XUIConfig isPhone]

#define is_iphone4                                          ([XUIConfig deviceModel] == XDeviceModelIPhone4)
#define is_iphone4_portrait                                 (is_iphone4 && is_portrait)
#define is_iphone4_landscape                                (is_iphone4 && is_landscape)

#define is_iphone5                                          ([XUIConfig deviceModel] == XDeviceModelIPhone5)
#define is_iphone5_portrait                                 (is_iphone5 && is_portrait)
#define is_iphone5_landscape                                (is_iphone5 && is_landscape)

#define is_iphone6                                          ([XUIConfig deviceModel] == XDeviceModelIPhone6)
#define is_iphone6_portrait                                 (is_iphone6 && is_portrait)
#define is_iphone6_landscape                                (is_iphone6 && is_landscape)

#define is_iphone6plus                                      ([XUIConfig deviceModel] == XDeviceModelIPhone6p)
#define is_iphone6plus_portrait                             (is_iphone6p && is_portrait)
#define is_iphone6plus_landscape                            (is_iphone6p && is_landscape)

#define is_ipad                                             [XUIConfig isPad]
#define is_ipad_portrait                                    (is_ipad && is_portrait)
#define is_ipad_landscape                                   (is_ipad && is_landscape)

#define universal_value(iphone, ipad)                       (is_iphone ? (iphone) : (ipad))
#define universal_value_4_5_d(v4, v5, vd)                   (is_iphone4 ? (v4) : universal_value(v5, vd))
#define universal_value_4_5_6_d(v4, v5, v6, vd)             (is_iphone6 ? (v6) : universal_value_4_5_d(v4, v5, vd))
#define universal_value_4_5_6_6p_d(v4, v5, v6, v6p, vd)     (is_iphone6plus ? (v6p) : universal_value_4_5_6_d(v4, v5, v6, vd))

#define resize_value(iphone4, ipad)                         [XUIConfig resizeValue:iphone4 pad:ipad]
#define resize_valueh(iphone4)                              [XUIConfig resizeValue:iphone4]
#define resize_valuev(iphone4)                              [XUIConfig resizeValueV:iphone4]
#define resize_font(iphone4)                                ceilf(resize_valueh(iphone4 * 4.0f / 3.0f) * 3.0f / 4.0f)

#define main_screen_width                                   [[UIScreen mainScreen] bounds].size.width
#define main_screen_height                                  [[UIScreen mainScreen] bounds].size.height

#define is_align_left(align)                                (align & XAlignLeft)
#define is_align_right(align)                               (align & XAlignRight)
#define is_align_top(align)                                 (align & XAlignTop)
#define is_align_bottom(align)                              (align & XAlignBottom)
#define is_align_hcenter(align)                             (align & XAlignHCenter)
#define is_align_vcenter(align)                             (align & XAlignVCenter)


#define XUICONFIG_INLINE                                    static inline

void XUICONFIG_INLINE set_view_w(UIView * view, CGFloat w) {
    
    CGRect f = view.frame; f.size.width = w; view.frame = f;
}

void XUICONFIG_INLINE set_view_h(UIView * view, CGFloat h) {
    
    CGRect f = view.frame; f.size.height = h; view.frame = f;
}

void XUICONFIG_INLINE set_view_x(UIView * view, CGFloat x) {
    
    CGRect f = view.frame; f.origin.x = x; view.frame = f;
}

void XUICONFIG_INLINE set_view_y(UIView * view, CGFloat y) {
    
    CGRect f = view.frame; f.origin.y = y; view.frame = f;
}

void XUICONFIG_INLINE set_view_l(UIView * view, CGFloat l) {
    
    CGRect f = view.frame; f.size.width = f.size.width + f.origin.x - l; f.origin.x = l; view.frame = f;
}

void XUICONFIG_INLINE set_view_t(UIView * view, CGFloat t) {
    
    CGRect f = view.frame; f.size.height = f.size.height + f.origin.y - t; f.origin.y = t; view.frame = f;
}

void XUICONFIG_INLINE set_view_r(UIView * view, CGFloat r) {
    
    CGRect f = view.frame; CGRect pf = view.superview.frame;
    f.size.width = pf.size.width - f.origin.x - r; view.frame = f;
}

void XUICONFIG_INLINE set_view_b(UIView * view, CGFloat b) {
    
    CGRect f = view.frame; CGRect pf = view.superview.frame;
    f.size.height = pf.size.height - f.origin.y - b; view.frame = f;
}

void XUICONFIG_INLINE set_view_xw(UIView * view, CGFloat x, CGFloat w) {
    
    CGRect f = view.frame; f.origin.x = x; f.size.width = w; view.frame = f;
}

void XUICONFIG_INLINE set_view_yh(UIView * view, CGFloat y, CGFloat h) {
    
    CGRect f = view.frame; f.origin.y = y; f.size.height = h; view.frame = f;
}

void XUICONFIG_INLINE set_view_rw(UIView * view, CGFloat r, CGFloat w) {
    
    CGRect f = view.frame; CGRect pf = view.superview.frame;
    f.origin.x = pf.size.width - r - w; f.size.width = w; view.frame = f;
}

void XUICONFIG_INLINE set_view_bh(UIView * view, CGFloat b, CGFloat h) {
    
    CGRect f = view.frame; CGRect pf = view.superview.frame;
    f.origin.y = pf.size.height - b - h; f.size.height = h; view.frame = f;
}

void XUICONFIG_INLINE set_view_cw(UIView * view, CGFloat w) {
    
    CGRect f = view.frame; CGRect pf = view.superview.frame;
    f.origin.x = (pf.size.width - w) / 2; f.size.width = w; view.frame = f;
}

void XUICONFIG_INLINE set_view_ch(UIView * view, CGFloat h) {
    
    CGRect f = view.frame; CGRect pf = view.superview.frame;
    f.origin.y = (pf.size.height - h) / 2; f.size.height = h; view.frame = f;
}

void XUICONFIG_INLINE set_view_lr(UIView * view, CGFloat l, CGFloat r) {
    
    CGRect f = view.frame; CGRect pf = view.superview.frame;
    f.origin.x = l; f.size.width = pf.size.width - l - r; view.frame = f;
}

void XUICONFIG_INLINE set_view_tb(UIView * view, CGFloat t, CGFloat b) {
    
    CGRect f = view.frame; CGRect pf = view.superview.frame;
    f.origin.y = t; f.size.height = pf.size.height - t - b; view.frame = f;
}

CGFloat XUICONFIG_INLINE get_fit_size_w(UIView * view) {
    
    return [view sizeThatFits:CGSizeMake(CGFLOAT_MAX, view.frame.size.height)].width;
}

CGFloat XUICONFIG_INLINE get_fit_size_h(UIView * view) {
    
    return [view sizeThatFits:CGSizeMake(view.frame.size.width, CGFLOAT_MAX)].height;
}

CGRect calcAlignFrame(CGRect frame, CGSize size, XAlign align);
