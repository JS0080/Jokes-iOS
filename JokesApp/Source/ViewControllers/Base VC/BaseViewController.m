//
//  BaseViewController.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

+ (id) newInstance {
    
    Class class = [self class];
    NSString * name = NSStringFromClass(class);
    BaseViewController * vc = [class alloc];
    
    return [vc initWithNibName:name bundle:nil];
}

- (instancetype) init {
    
    self = [super init];
    if (self)
        [self setup];
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self)
        [self setup];
    
    return self;
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
        [self setup];
    
    return self;
}

- (void) setup {
    
    [self initController];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self setupController];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self setupLanguage];
}

- (void) initController {
    
}

- (void) setupController {
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
}

- (void) setupAppearance {
    
}

- (void) setupLayout {
    
    [self.view layoutIfNeeded];
}

- (void) setupLanguage {
    
}

@end
