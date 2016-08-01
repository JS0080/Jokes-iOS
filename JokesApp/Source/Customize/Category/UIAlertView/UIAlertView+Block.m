//
//  UIAlertView+Block.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "UIAlertView+Block.h"

@interface UIBlockAlertViewDelegation : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy) UIAlertViewButtonClickedBlock buttonClickedBlock;
@property (nonatomic, copy) UIAlertViewButtonClickedBlock otherBlock;
@property (nonatomic, copy) UIAlertViewButtonClickedBlock cancelBlock;

@end

@implementation UIAlertView (Block)

UIBlockAlertViewDelegation * _blockDelegation;

- (void)showWithButtonClickedBlock:(UIAlertViewButtonClickedBlock)buttonClickedBlock {

    if (_blockDelegation == nil)
        _blockDelegation = [[UIBlockAlertViewDelegation alloc] init];
    
    _blockDelegation.buttonClickedBlock = buttonClickedBlock;
    _blockDelegation.otherBlock = nil;
    _blockDelegation.cancelBlock = nil;
    self.delegate = _blockDelegation;
    
    [self show];
}

- (void)showWithOtherBlock:(UIAlertViewButtonClickedBlock)otherBlock {
    
    if (_blockDelegation == nil)
        _blockDelegation = [[UIBlockAlertViewDelegation alloc] init];
    
    _blockDelegation.buttonClickedBlock = nil;
    _blockDelegation.otherBlock = otherBlock;
    _blockDelegation.cancelBlock = nil;
    self.delegate = _blockDelegation;
    
    [self show];
}

- (void)showWithOtherBlock:(UIAlertViewButtonClickedBlock)otherBlock cancelBlock:(UIAlertViewButtonClickedBlock)cancelBlock {
    
    if (_blockDelegation == nil)
        _blockDelegation = [[UIBlockAlertViewDelegation alloc] init];
    
    _blockDelegation.buttonClickedBlock = nil;
    _blockDelegation.otherBlock = otherBlock;
    _blockDelegation.cancelBlock = cancelBlock;
    self.delegate = _blockDelegation;
    
    [self show];
}

- (void)showWithCancelBlock:(UIAlertViewButtonClickedBlock)cancelBlock {
    
    if (_blockDelegation == nil)
        _blockDelegation = [[UIBlockAlertViewDelegation alloc] init];
    
    _blockDelegation.buttonClickedBlock = nil;
    _blockDelegation.otherBlock = nil;
    _blockDelegation.cancelBlock = cancelBlock;
    self.delegate = _blockDelegation;
    
    [self show];
}

@end


@implementation UIBlockAlertViewDelegation

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (_buttonClickedBlock) {
        
        _buttonClickedBlock(buttonIndex);
    }
    
    if (buttonIndex == [alertView cancelButtonIndex]) {

        if (_cancelBlock) {
            
            _cancelBlock(buttonIndex);
        }
    }
    else {
        
        if (_otherBlock) {
            
            _otherBlock(buttonIndex);
        }
    }
}

@end
