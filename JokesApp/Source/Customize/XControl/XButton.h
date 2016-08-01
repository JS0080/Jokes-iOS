//
//  XButton.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XUIConfig.h"

@interface XButton : UIButton

@property (nonatomic, retain) UIColor *     backColor;
@property (nonatomic, retain) UIColor *     backSelColor;
@property (nonatomic, retain) UIColor *     backDisColor;
@property (nonatomic, retain) UIColor *     borderColor;
@property (nonatomic, retain) UIColor *     borderSelColor;
@property (nonatomic, retain) UIColor *     borderDisColor;
@property (nonatomic, assign) CGFloat       cornerRound;
@property (nonatomic, assign) CGFloat       cornerRoundTL;
@property (nonatomic, assign) CGFloat       cornerRoundTR;
@property (nonatomic, assign) CGFloat       cornerRoundBL;
@property (nonatomic, assign) CGFloat       cornerRoundBR;
@property (nonatomic, assign) XAlign        imagePosition;
@property (nonatomic, assign) XAlign        alignImage;
@property (nonatomic, assign) XAlign        alignText;
@property (nonatomic, assign) CGSize        sizeImage;
@property (nonatomic, assign) CGFloat       zoomScale;
@property (nonatomic, assign) CGFloat       pressAlpha;
@property (nonatomic, assign) CGFloat       borderWidth;
@property (nonatomic, assign) BOOL          scaleFit;

@end
