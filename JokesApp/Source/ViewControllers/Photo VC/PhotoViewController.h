//
//  PhotoViewController.h
//  JokesApp
//
//  Created by Michael Lee on 1/30/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoZoomingScrollView.h"
#import "PhotoBrowserData.h"

@protocol PhotoBrowserDelegate <NSObject>

@optional
- (void) photoBrowser:(PhotoViewController *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;

@end

@interface PhotoViewController : UIViewController

@property (nonatomic, retain) id<PhotoBrowserDelegate> delegate;
@property (nonatomic, retain) PhotoBrowserData *    browseData;
@property (nonatomic, assign) NSUInteger            category;
@property (nonatomic, assign) NSUInteger            delayToHideElements;
@property (nonatomic, assign) BOOL                  alwaysShowControls;
@property (nonatomic, assign) BOOL                  leaveStatusBarAlone;

// Reloads the photo browser and refetches data
- (void) reloadData;

// Set page that photo browser starts on
- (void) setCurrentPhotoIndex:(NSUInteger)index;

// Navigation
- (void) showNextPhotoAnimated:(BOOL)animated;
- (void) showPreviousPhotoAnimated:(BOOL)animated;


// Layout
- (void) layoutVisiblePages;
- (void) performLayout;

// Paging
- (void) tilePages;
- (BOOL) isDisplayingPageForIndex:(NSUInteger)index;
- (PhotoZoomingScrollView *) pageDisplayedAtIndex:(NSUInteger)index;
- (PhotoZoomingScrollView *) pageDisplayingPhoto:(id<MWPhoto>)photo;
- (PhotoZoomingScrollView *) dequeueRecycledPage;
- (void) configurePage:(PhotoZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void) didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)  frameForPagingScrollView;
- (CGRect)  frameForPageAtIndex:(NSUInteger)index;
- (CGSize)  contentSizeForPagingScrollView;
- (CGPoint) contentOffsetForPageAtIndex:(NSUInteger)index;

// Navigation
- (void) jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void) gotoPreviousPage;
- (void) gotoNextPage;

// Data
- (void) loadAdjacentPhotosIfNecessary:(id<MWPhoto>)photo;

// Controls
- (void) cancelControlHiding;
- (void) hideControlsAfterDelay;
- (void) setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void) toggleControls;
- (BOOL) areControlsHidden;
- (void) updateNavigation;
- (void) setNavBarAppearance:(BOOL)animated;
- (void) storePreviousNavBarAppearance;
- (void) restorePreviousNavBarAppearance:(BOOL)animated;
- (BOOL) presentingViewControllerPrefersStatusBarHidden;

@end
