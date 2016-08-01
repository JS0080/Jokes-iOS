//
//  AppDelegate.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *            window;
@property (nonatomic, retain) MainViewController *  mainVC;

+ (AppDelegate *) sharedDelegate;

- (void) showWaitingAlert:(BOOL)show message:(NSString *)message;

@end

