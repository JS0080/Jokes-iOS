//
//  SplashViewController.m
//  JokesApp
//
//  Created by Michael Lee on 1/29/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (void) setupController {
    
    [super setupController];
    
    [self performSelector:@selector(gotoMain) withObject:nil afterDelay:2.0];
}

- (void) gotoMain {
    
    [UIView transitionWithView:self.navigationController.view duration:1.0f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [self.navigationController popToRootViewControllerAnimated:NO];
                    }
                    completion:nil];
}

@end
