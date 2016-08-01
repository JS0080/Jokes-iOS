//
//  BaseViewController.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtil.h"
#import "AppSetting.h"
#import "XUIConfig.h"
#import "NSString+Utilities.h"
#import "Global.h"

@interface BaseViewController : UIViewController

+ (id) newInstance;

- (void) initController;
- (void) setupController;
- (void) setupAppearance;
- (void) setupLayout;
- (void) setupLanguage;

@end
