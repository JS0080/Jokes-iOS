//
//  XButton.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "XButton.h"
#import "UIColor+Utilities.h"

@interface XButton ()

@end

@implementation XButton

#pragma mark - Initialization

- (instancetype) init {
    
    self = [super init];
    if (self) [self setup];
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) [self setup];
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) [self setup];
    return self;
}

#pragma mark - Setup

- (void) setup {
    
    self.backColor = [UIColor clearColor];
    self.backSelColor = nil;
    self.backDisColor = nil;
    self.borderColor = [UIColor clearColor];
    self.borderSelColor = nil;
    self.borderDisColor = [UIColor clearColor];
    self.cornerRound = 0.0f;
    self.borderWidth = 1.0f;
    self.zoomScale = 1.0f;
    self.pressAlpha = 0.6f;
    self.adjustsImageWhenHighlighted = NO;
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.imagePosition = XAlignLeft;
    self.alignImage = XAlignRightCenter;
    self.alignText = XAlignCenter;
    self.sizeImage = CGSizeZero;
    self.scaleFit = NO;
    
    [self addTarget:self action:@selector(wasPressed) forControlEvents:(UIControlEventTouchDown       |
                                                                        UIControlEventTouchDownRepeat |
                                                                        UIControlEventTouchDragInside |
                                                                        UIControlEventTouchDragEnter)];
    [self addTarget:self action:@selector(endPressed) forControlEvents:(UIControlEventTouchCancel      |
                                                                        UIControlEventTouchDragOutside |
                                                                        UIControlEventTouchDragExit    |
                                                                        UIControlEventTouchUpInside    |
                                                                        UIControlEventTouchUpOutside)];
}

- (void) setupDisableColor {
    
    if ([_backColor isLightColor])
        [self setTitleColor:[UIColor colorWithWhite:0.4f alpha:0.5f] forState:UIControlStateDisabled];
    else
        [self setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    
    [self setNeedsDisplay];
}

- (void) setBorderColor:(UIColor *)borderColor {
    
    _borderColor = borderColor;
    [self setNeedsDisplay];
}

#pragma mark - Setter

- (void) setBackColor:(UIColor *)backColor {
    
    _backColor = backColor;
    self.backgroundColor = [UIColor clearColor];
    
    [self setupDisableColor];
}

- (void) setImagePosition:(XAlign)imagePosition {
    
    _imagePosition = imagePosition;
    [self setNeedsLayout];
}

- (void) setAlignImage:(XAlign)alignImage {
    
    _alignImage = alignImage;
    [self setNeedsLayout];
}

- (void) setAlignText:(XAlign)alignText {
    
    _alignText = alignText;
    [self setNeedsLayout];
}

- (void) setSizeImage:(CGSize)sizeImage {
    
    _sizeImage = sizeImage;
    [self setNeedsLayout];
}

- (void) setCornerRound:(CGFloat)cornerRound {
    
    _cornerRound = cornerRound;
    _cornerRoundTL = cornerRound;
    _cornerRoundTR = cornerRound;
    _cornerRoundBL = cornerRound;
    _cornerRoundBR = cornerRound;
}

- (void) setSelected:(BOOL)selected {
    
    [super setSelected:selected];
}

- (void) setHighlighted:(BOOL)highlighted {
    
    if (_backSelColor || _borderSelColor)
        [self setNeedsDisplay];
    
    [super setHighlighted:highlighted];
}

- (void) wasPressed {
    
    [UIView animateWithDuration:0.1f animations:^{
        
        self.alpha = self.pressAlpha;
//        self.titleLabel.alpha = self.pressAlpha;
//        self.imageView.alpha = self.pressAlpha;
    }];
}

- (void) endPressed {
    
    [UIView animateWithDuration:0.3f animations:^{
        
        self.alpha = 1.0f;
//        self.titleLabel.alpha = 1.0f;
//        self.imageView.alpha = 1.0f;
    }];
}

#pragma mark - Drawing

- (void) drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context)
        return;
    
    [self drawXButtonInRect:rect withContext:&context];
}

- (void) drawXButtonInRect:(CGRect)rect withContext:(CGContextRef *)context {
    
    CGContextSaveGState(*context);
    
    UIColor * backColor = _backColor;
    UIColor * borderColor = _borderColor;
    
    if (self.highlighted) {
        
        if (_backSelColor)
            backColor = _backSelColor;
        else if (self.pressAlpha == 1.0f)
            backColor = [backColor darkenColorWithValue:0.06f];
        
        if (_borderSelColor)
            borderColor = _borderSelColor;
        else if (self.pressAlpha == 1.0f)
            borderColor = [borderColor darkenColorWithValue:0.06f];
    }
    
    if (!self.enabled) {
        
        if (_backDisColor)
            backColor = _backDisColor;
        else {
            
            CGFloat r, g, b, a;
            
            [_backColor getRed:&r green:&g blue:&b alpha:&a];
            backColor = RGBA_F(r, g, b, 0.4f);
            //backColor = [backColor desaturatedColorToPercentSaturation:0.60f];
        }
        
        if (_borderDisColor)
            borderColor = _borderDisColor;
    }
    
    CGContextSetFillColorWithColor(*context, backColor.CGColor);
    CGContextSetStrokeColorWithColor(*context, borderColor.CGColor);
    
    CGContextSetLineWidth(*context, _borderWidth);
    
    CGFloat minx = 0, midx = rect.size.width / 2, maxx = rect.size.width;
    CGFloat miny = 0, midy = rect.size.height / 2, maxy = rect.size.height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minx, midy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, _cornerRoundTL);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, _cornerRoundTR);
    CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, _cornerRoundBR);
    CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, _cornerRoundBL);
    CGPathCloseSubpath(path);
    
//    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)
//                                                    cornerRadius:_cornerRound];
    
    CGContextAddPath(*context, path);
    CGContextClip(*context);
    CGContextAddPath(*context, path);
    CGContextDrawPath(*context, kCGPathFillStroke);
    CGContextRestoreGState(*context);
}

#pragma mark - Layout

- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    UIEdgeInsets imgInset, textInset;
    UIImage * image;
    CGSize szOrgImage;
    
    imgInset = [self imageEdgeInsets];
    textInset = [self titleEdgeInsets];
    
    image = [self imageForState:[self state]];
    
    if (image == nil)
        image = [self imageForState:UIControlStateNormal];
    if (image == nil)
        szOrgImage = CGSizeZero;
    else
        szOrgImage = image.size;
    
    CGSize szText = [self calcTextSize:self.frame.size];
    CGSize szImage = [self calcImageSize:szOrgImage textSize:szText fitSize:self.frame.size];
    CGSize szButton = self.frame.size;
    CGRect frmImage, frmText;
    
    if (is_align_left(_imagePosition))
        frmText = CGRectMake(imgInset.left + imgInset.right + szImage.width + textInset.left, textInset.top, szButton.width - imgInset.left - imgInset.right - szImage.width - textInset.left - textInset.right, szButton.height - textInset.top - textInset.bottom);
    else if (is_align_right(_imagePosition))
        frmText = CGRectMake(textInset.left, textInset.top, szButton.width - imgInset.left - imgInset.right - szImage.width - textInset.left - textInset.right, szButton.height - textInset.top - textInset.bottom);
    else if (is_align_top(_imagePosition))
        frmText = CGRectMake(textInset.left, imgInset.top + imgInset.bottom + szImage.width + textInset.top, szButton.width - textInset.left - textInset.right, szButton.height - imgInset.top - imgInset.bottom - szImage.height - textInset.top - textInset.bottom);
    else if (is_align_bottom(_imagePosition))
        frmText = CGRectMake(textInset.left, textInset.top, szButton.width - textInset.left - textInset.right, szButton.height - imgInset.top - imgInset.bottom - szImage.height - textInset.top - textInset.bottom);
    
    frmText = calcAlignFrame(frmText, szText, _alignText);
    
    if (is_align_left(_imagePosition))
        frmImage = CGRectMake(imgInset.left, imgInset.top, frmText.origin.x - imgInset.left - imgInset.right, szButton.height - imgInset.top - imgInset.bottom);
    else if (is_align_right(_imagePosition))
        frmImage = CGRectMake(CGRectGetMaxX(frmText) + imgInset.left, imgInset.top, szButton.width - imgInset.right - imgInset.left - CGRectGetMaxX(frmText), szButton.height - imgInset.top - imgInset.bottom);
    else if (is_align_top(_imagePosition))
        frmImage = CGRectMake(imgInset.left, imgInset.top, szButton.width - imgInset.left - imgInset.right, frmText.origin.y - imgInset.top - imgInset.bottom);
    else if (is_align_bottom(_imagePosition))
        frmImage = CGRectMake(imgInset.left, CGRectGetMaxY(frmText) + imgInset.top, szButton.width - imgInset.left - imgInset.right, szButton.height - imgInset.top - imgInset.bottom - CGRectGetMaxY(frmText));
    
    frmImage = calcAlignFrame(frmImage, szImage, _alignImage);
    
    self.imageView.frame = frmImage;
    self.titleLabel.frame = frmText;
    
    if (self.highlighted)
        self.imageView.transform = CGAffineTransformMakeScale(self.zoomScale, self.zoomScale);
    else
        self.imageView.transform = CGAffineTransformIdentity;
}

- (CGSize) calcImageSize:(CGSize)szOrgImage textSize:(CGSize)szText fitSize:(CGSize)sizeFit {
    
    UIEdgeInsets imgInset = [self imageEdgeInsets];
    UIEdgeInsets txtInset = [self titleEdgeInsets];
    CGSize szImage = szOrgImage;
    CGSize szMax;
    
    if (szOrgImage.width == 0.0 || szOrgImage.height == 0.0) return CGSizeZero;
    
    if (_sizeImage.width != 0.0 && _sizeImage.height != 0.0)
        szImage = _sizeImage;
    else
        szImage = szOrgImage;
    
    if (is_align_left(_imagePosition) || is_align_right(_imagePosition)) {
        
        szMax.width = sizeFit.width - imgInset.left - imgInset.right - txtInset.left - txtInset.right - szText.width;
        szMax.height = sizeFit.height - imgInset.top - imgInset.bottom;
    }
    else if (is_align_top(_imagePosition) || is_align_bottom(_imagePosition)) {
        
        szMax.width = sizeFit.width - imgInset.left - imgInset.right;
        szMax.height = sizeFit.height - imgInset.top - imgInset.bottom - txtInset.top - txtInset.bottom - szText.height;
    }
    
    if (szMax.width <= 0 || szMax.height <= 0)
        return CGSizeZero;
    
    if (!self.scaleFit && szMax.width >= szImage.width && szMax.height >= szImage.height)
        return szImage;
    
    CGFloat ratio = MIN(szMax.width / szImage.width, szMax.height / szImage.height);
    
    szImage.width = szImage.width * ratio;
    szImage.height = szImage.height * ratio;
    
    return szImage;
}

- (CGSize) calcTextSize:(CGSize)sizeFit {
    
    UIEdgeInsets textInset = [self titleEdgeInsets];
    CGSize szMax, szText;
    
    szMax = CGSizeMake(sizeFit.width - textInset.left - textInset.right, sizeFit.height - textInset.top - textInset.bottom);
    szText = [self.titleLabel sizeThatFits:szMax];
    
    szText.width = MIN(szText.width, szMax.width);
    szText.height = MIN(szText.height, szMax.height);
    
    return szText;
}

- (CGSize) sizeThatFits:(CGSize)size {
    
    UIEdgeInsets imgInset = [self imageEdgeInsets];
    UIEdgeInsets txtInset = [self titleEdgeInsets];
    CGSize sizeFit;
    CGSize szOrgImage;
    UIImage * image;
    
    image = [self imageForState:[self state]];
    
    if (image == nil)
        image = [self imageForState:UIControlStateNormal];
    if (image == nil)
        szOrgImage = CGSizeZero;
    else
        szOrgImage = image.size;
    
    CGSize szText = [self calcTextSize:size];
    CGSize szImage = [self calcImageSize:szOrgImage textSize:szText fitSize:size];
    
    szText.width += txtInset.left + txtInset.right;
    szText.height += txtInset.top + txtInset.bottom;
    szImage.width += imgInset.left + imgInset.right;
    szImage.height += imgInset.top + imgInset.bottom;
    
    if (is_align_left(_imagePosition) || is_align_right(_imagePosition))
        sizeFit = CGSizeMake(szText.width + szImage.width, MAX(szText.height, szImage.height));
    else
        sizeFit = CGSizeMake(MAX(szText.width, szImage.width), szText.height + szImage.height);
    
    return sizeFit;
}

@end
