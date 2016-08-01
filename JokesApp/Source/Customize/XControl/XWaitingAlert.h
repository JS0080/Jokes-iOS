//
//  XWaitingAlert.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

typedef void (^XWaitingAlertCompletionBlock)();

@protocol XWaitingAlertDelegate;


typedef enum {
    
	XWaitingAlertModeIndeterminate,
	XWaitingAlertModeDeterminate,
	XWaitingAlertModeDeterminateHorizontalBar,
	XWaitingAlertModeAnnularDeterminate,
	XWaitingAlertModeCustomView,
	XWaitingAlertModeText
} XWaitingAlertMode;

typedef enum {
    
	XWaitingAlertAnimationFade,
	XWaitingAlertAnimationZoom,
	XWaitingAlertAnimationZoomOut = XWaitingAlertAnimationZoom,
	XWaitingAlertAnimationZoomIn
} XWaitingAlertAnimation;


@interface XWaitingAlert : UIView

+ (instancetype)showWaitingAddedTo:(UIView *)view animated:(BOOL)animated;
+ (BOOL)hideWaitingAddedTo:(UIView *)view animated:(BOOL)animated;
+ (NSUInteger)hideAllWaitingsForView:(UIView *)view animated:(BOOL)animated;
+ (instancetype)WaitingForView:(UIView *)view;

+ (NSArray *)allWaitingsForView:(UIView *)view;

- (id)initWithWindow:(UIWindow *)window;
- (id)initWithView:(UIView *)view;

- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;
- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block;
- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block completionBlock:(XWaitingAlertCompletionBlock)completion;
- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue;
- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue
		  completionBlock:(XWaitingAlertCompletionBlock)completion;

@property (nonatomic, copy) XWaitingAlertCompletionBlock completionBlock;
@property (nonatomic, assign) XWaitingAlertMode mode;
@property (nonatomic, assign) XWaitingAlertAnimation animationType;
@property (nonatomic, retain) UIView *customView;
@property (nonatomic, retain) id<XWaitingAlertDelegate> delegate;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, copy) NSString *detailsLabelText;
@property (nonatomic, assign) float opacity;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) float xOffset;
@property (nonatomic, assign) float yOffset;
@property (nonatomic, assign) float margin;
@property (nonatomic, assign) float cornerRadius;
@property (nonatomic, assign) BOOL dimBackground;
@property (nonatomic, assign) float graceTime;
@property (nonatomic, assign) float minShowTime;
@property (nonatomic, assign) BOOL taskInProgress;
@property (nonatomic, assign) BOOL removeFromSuperViewOnHide;
@property (nonatomic, retain) UIFont* labelFont;
@property (nonatomic, retain) UIColor* labelColor;
@property (nonatomic, retain) UIFont* detailsLabelFont;
@property (nonatomic, retain) UIColor* detailsLabelColor;
@property (nonatomic, retain) UIColor *activityIndicatorColor;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) CGSize minSize;
@property (atomic, assign, readonly) CGSize size;
@property (nonatomic, assign, getter = isSquare) BOOL square;

@end


@protocol XWaitingAlertDelegate <NSObject>

@optional

- (void)waitingWasHidden:(XWaitingAlert *)hud;

@end


@interface XRoundProgressView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, retain) UIColor *progressTintColor;
@property (nonatomic, retain) UIColor *backgroundTintColor;
@property (nonatomic, assign, getter = isAnnular) BOOL annular;

@end


@interface XBarProgressView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, retain) UIColor *lineColor;
@property (nonatomic, retain) UIColor *progressRemainingColor;
@property (nonatomic, retain) UIColor *progressColor;

@end
