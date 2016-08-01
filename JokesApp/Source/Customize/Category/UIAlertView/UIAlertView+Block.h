//
//  UIAlertView+Block.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIAlertViewButtonClickedBlock)(NSInteger buttonIndex);

@interface UIAlertView (Block)

- (void) showWithButtonClickedBlock:(UIAlertViewButtonClickedBlock)buttonClickedBlock;
- (void) showWithOtherBlock:(UIAlertViewButtonClickedBlock)otherBlock;
- (void) showWithOtherBlock:(UIAlertViewButtonClickedBlock)otherBlock cancelBlock:(UIAlertViewButtonClickedBlock)cancelBlock;
- (void) showWithCancelBlock:(UIAlertViewButtonClickedBlock)cancelBlock;

@end
