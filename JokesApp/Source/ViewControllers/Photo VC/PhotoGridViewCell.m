//
//  PhotoGridViewCell.m
//  JokesApp
//
//  Created by Michael Lee on 1/30/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "PhotoGridViewCell.h"
#import "UIColor+Utilities.h"

@implementation PhotoGridViewCell

- (void) awakeFromNib {
    
    [_viewBorder.layer setBorderColor:[RGB_I(146, 208, 255) CGColor]];
    [_viewBorder.layer setBorderWidth:1.0f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                 name:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) prepareForReuse {
    
    _photo = nil;
    _imvPhoto.image = nil;
    
    [self hideImageFailure];
    [super prepareForReuse];
}

- (void) setPhoto:(id <MWPhoto>)photo {
    
    _photo = photo;
    
    if (_photo) {
        
    } else {
        
        [self showImageFailure];
    }
}

- (void) displayImage {
    
    _imvPhoto.image = [_photo underlyingImage];
    [self hideImageFailure];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _imvPhoto.alpha = 0.6;
    _imvFail.alpha = 0.6;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _imvPhoto.alpha = 1;
    _imvFail.alpha = 1;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _imvPhoto.alpha = 1;
    _imvFail.alpha = 1;
    [super touchesCancelled:touches withEvent:event];
}

- (void) showImageFailure {
    
    _imvPhoto.image = nil;
    _imvFail.hidden = NO;
}

- (void) hideImageFailure {
    
    _imvFail.hidden = YES;
}

- (void) handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    
    id <MWPhoto> photo = [notification object];
    if (photo == _photo) {
        
        if ([photo underlyingImage]) {
            
            // Successful load
            [self displayImage];
        } else {
            
            // Failed to load
            [self showImageFailure];
        }
    }
}

@end
