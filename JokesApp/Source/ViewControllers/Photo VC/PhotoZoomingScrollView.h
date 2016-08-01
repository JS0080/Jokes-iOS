//
//  PhotoZoomingScrollView.h
//  JokesApp
//
//  Created by Michael Lee on 1/30/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"
#import "MWPhoto.h"

@class PhotoViewController;

@interface PhotoZoomingScrollView : UIScrollView <UIScrollViewDelegate, MWTapDetectingImageViewDelegate, MWTapDetectingViewDelegate>

@property (nonatomic, assign) NSUInteger    index;
@property (nonatomic, assign) id <MWPhoto>  photo;

- (id) initWithPhotoBrowser:(PhotoViewController *)photoBrowser;
- (void) displayImage;
- (void) displayImageFailure;
- (void) setMaxMinZoomScalesForCurrentBounds;
- (void) prepareForReuse;
- (void) setImageHidden:(BOOL)hidden;

@end
