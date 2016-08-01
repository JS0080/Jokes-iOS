//
//  PhotoViewController.m
//  JokesApp
//
//  Created by Michael Lee on 1/30/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoZoomingScrollView.h"
#import "RequestService.h"
#import "AppSetting.h"
#import "AppDelegate.h"
#import "CommonUtil.h"
#import "RD_Rate.h"
#import "XToast.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define PADDING                  10

@interface PhotoViewController () <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *     pagingScrollView;
@property (weak, nonatomic) IBOutlet UILabel *          txtRate;
@property (weak, nonatomic) IBOutlet UIButton *         btnPrev;
@property (weak, nonatomic) IBOutlet UIButton *         btnNext;
@property (weak, nonatomic) IBOutlet UIButton *         btnShare;
@property (weak, nonatomic) IBOutlet GADBannerView *    bannerView;

@property (nonatomic, assign) NSUInteger        pageIndexBeforeRotation;
@property (nonatomic, assign) NSUInteger        previousPageIndex;
@property (nonatomic, assign) CGRect            previousLayoutBounds;

@property (nonatomic, assign) BOOL              performingLayout;
@property (nonatomic, assign) BOOL              rotating;
@property (nonatomic, assign) BOOL              viewIsActive;
@property (nonatomic, assign) BOOL              viewHasAppearedInitially;
@property (nonatomic, assign) BOOL              skipNextPagingScrollViewPositioning;

@property (nonatomic, retain) NSMutableSet *    visiblePages;
@property (nonatomic, retain) NSMutableSet *    recycledPages;

// Navigation & Control
@property (nonatomic, retain) NSTimer *         controlVisibilityTimer;
@property (nonatomic, assign) BOOL              previousNavBarHidden;
@property (nonatomic, assign) BOOL              previousNavBarTranslucent;
@property (nonatomic, assign) UIBarStyle        previousNavBarStyle;
@property (nonatomic, assign) UIStatusBarStyle  previousStatusBarStyle;
@property (nonatomic, retain) UIColor *         previousNavBarTintColor;
@property (nonatomic, retain) UIColor *         previousNavBarBarTintColor;
@property (nonatomic, retain) UIBarButtonItem * previousViewControllerBackButton;
@property (nonatomic, retain) UIBarButtonItem * doneButton;
@property (nonatomic, retain) UIImage *         previousNavigationBarBackgroundImageDefault;
@property (nonatomic, retain) UIImage *         previousNavigationBarBackgroundImageLandscapePhone;
@property (nonatomic, assign) BOOL              isVCBasedStatusBarAppearance;
@property (nonatomic, assign) BOOL              statusBarShouldBeHidden;
@property (nonatomic, assign) BOOL              didSavePreviousStateOfNavBar;
@property (nonatomic, assign) BOOL              hasBelongedToViewController;
@property (nonatomic, assign) BOOL              controlsHidden;
@property (nonatomic, retain) UIActivityViewController * activityViewController;

@property (nonatomic, assign) CGSize            befSize;

@end

@implementation PhotoViewController

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        [self _initialization];
    }
    
    return self;
}

- (void) _initialization {
    
    NSNumber * isVCBasedStatusBarAppearanceNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIViewControllerBasedStatusBarAppearance"];
    if (isVCBasedStatusBarAppearanceNum) {
        _isVCBasedStatusBarAppearance = isVCBasedStatusBarAppearanceNum.boolValue;
    } else {
        _isVCBasedStatusBarAppearance = YES; // default
    }
    self.hidesBottomBarWhenPushed = YES;
    
    _previousPageIndex   = NSUIntegerMax;
    _performingLayout    = NO;
    _rotating            = NO;
    _viewIsActive        = NO;
    _controlsHidden      = YES;
    _visiblePages        = [[NSMutableSet alloc] init];
    _recycledPages       = [[NSMutableSet alloc] init];
    _delayToHideElements = 5;
    _hasBelongedToViewController  = NO;
    _didSavePreviousStateOfNavBar = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Listen for MWPhoto notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                 name:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                               object:nil];
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) didReceiveMemoryWarning {
    
    // Release any cached data, images, etc that aren't in use.
    [_browseData releaseAllUnderlyingPhotos:YES];
    [_recycledPages removeAllObjects];
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
    
    // View
    self.view.backgroundColor = _browseData.backColor;
    self.view.clipsToBounds   = YES;
    
    // Setup paging scrolling view
//    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
//    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
//    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    _pagingScrollView.pagingEnabled    = YES;
//    _pagingScrollView.delegate         = self;
//    _pagingScrollView.showsHorizontalScrollIndicator = NO;
//    _pagingScrollView.showsVerticalScrollIndicator   = NO;
    _pagingScrollView.backgroundColor = _browseData.backColor;
    _pagingScrollView.contentSize     = [self contentSizeForPagingScrollView];
//    [self.view addSubview:_pagingScrollView];
    
    // Update
    [self reloadData];
    
    self.bannerView.adUnitID = @"ca-app-pub-6719410133925531/9403064001";
    self.bannerView.rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [self.bannerView loadRequest:[GADRequest request]];
    
    // Super
    [super viewDidLoad];
}

// Release any retained subviews of the main view.
- (void) viewDidUnload {
    
    _visiblePages = nil;
    _recycledPages = nil;
    
    [super viewDidUnload];
}

- (void) performLayout {
    
    // Setup
    _performingLayout = YES;
    
    // Setup pages
    [_visiblePages  removeAllObjects];
    [_recycledPages removeAllObjects];
    
    // Navigation buttons
    if ([self.navigationController.viewControllers objectAtIndex:0] == self) {
        
        // We're first on stack so show done button
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
        // Set appearance
        [_doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_doneButton setBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        [_doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [_doneButton setBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
        [_doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
        [_doneButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        self.navigationItem.rightBarButtonItem = _doneButton;
    }
    else {
        
        // We're not first so show back button
        UIViewController * previousViewController = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        NSString * backButtonTitle = previousViewController.navigationItem.backBarButtonItem ? previousViewController.navigationItem.backBarButtonItem.title : previousViewController.title;
        UIBarButtonItem * newBackButton = [[UIBarButtonItem alloc] initWithTitle:backButtonTitle style:UIBarButtonItemStylePlain target:nil action:nil];
        
        // Appearance
        [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [newBackButton setBackButtonBackgroundImage:nil forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];
        [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateNormal];
        [newBackButton setTitleTextAttributes:[NSDictionary dictionary] forState:UIControlStateHighlighted];
        _previousViewControllerBackButton = previousViewController.navigationItem.backBarButtonItem; // remember previous
        previousViewController.navigationItem.backBarButtonItem = newBackButton;
    }
    
    // Content offset
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_browseData.currentIndex];
    [self tilePages];
    [self updateNavigation];
    
    _performingLayout = NO;
}

- (BOOL) presentingViewControllerPrefersStatusBarHidden {
    
    UIViewController * presenting = self.presentingViewController;
    
    if (presenting) {
        
        if ([presenting isKindOfClass:[UINavigationController class]]) {
            presenting = [(UINavigationController *)presenting topViewController];
        }
    } else {
        
        // We're in a navigation controller so get previous one!
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            presenting = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        }
    }
    
    if (presenting) {
        return [presenting prefersStatusBarHidden];
    }
    
    return NO;
}

- (void) viewWillAppear:(BOOL)animated {
    
    // Super
    [super viewWillAppear:animated];
    
    // Status bar
    if (!_viewHasAppearedInitially) {
        
        _leaveStatusBarAlone = [self presentingViewControllerPrefersStatusBarHidden];
        // Check if status bar is hidden on first appear, and if so then ignore it
        if (CGRectEqualToRect([[UIApplication sharedApplication] statusBarFrame], CGRectZero)) {
            _leaveStatusBarAlone = YES;
        }
    }
    
    // Set style
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    }
    
    // Navigation bar appearance
    if (!_viewIsActive && [self.navigationController.viewControllers objectAtIndex:0] != self) {
        [self storePreviousNavBarAppearance];
    }
    [self setNavBarAppearance:animated];
    
    // Update UI
    [self hideControlsAfterDelay];
    
    // If rotation occured while we're presenting a modal
    // and the index changed, make sure we show the right one now
    if (_browseData.currentIndex != _pageIndexBeforeRotation) {
        
        [self jumpToPageAtIndex:_pageIndexBeforeRotation animated:NO];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    _viewIsActive = YES;
    _viewHasAppearedInitially = YES;
    
    if ([CommonUtil isInternetConnected] == NO) {
        
        [XToast showMessage:[NSString stringWithFormat:@"No connection is detected"]];
        return;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
    // Detect if rotation occurs while we're presenting a modal
    _pageIndexBeforeRotation = _browseData.currentIndex;
    
    // Check that we're being popped for good
    if ([self.navigationController.viewControllers objectAtIndex:0] != self &&
        ![self.navigationController.viewControllers containsObject:self]) {
        
        // State
        _viewIsActive = NO;
        
        // Bar state / appearance
        [self restorePreviousNavBarAppearance:animated];
    }
    
    // Controls
    [self.navigationController.navigationBar.layer removeAllAnimations]; // Stop all animations on nav bar
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
    [self setControlsHidden:NO animated:NO permanent:YES];
    
    // Status bar
    if (!_leaveStatusBarAlone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];
    }
    
    // Super
    [super viewWillDisappear:animated];
}

- (void) willMoveToParentViewController:(UIViewController *)parent {
    
//    if (parent && _hasBelongedToViewController) {
//        [NSException raise:@"PhotoBrowser Instance Reuse" format:@"PhotoBrowser instances cannot be reused."];
//    }
}

- (void) didMoveToParentViewController:(UIViewController *)parent {
    
//    if (!parent) _hasBelongedToViewController = YES;
}

- (void) setNavBarAppearance:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    UINavigationBar * navBar = self.navigationController.navigationBar;
    navBar.tintColor    = [UIColor whiteColor];
    navBar.barTintColor = nil;
    navBar.shadowImage  = nil;
    navBar.translucent  = YES;
    navBar.barStyle     = UIBarStyleBlackTranslucent;
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
}

- (void) storePreviousNavBarAppearance {
    
    _didSavePreviousStateOfNavBar = YES;
    _previousNavBarBarTintColor   = self.navigationController.navigationBar.barTintColor;
    _previousNavBarTranslucent    = self.navigationController.navigationBar.translucent;
    _previousNavBarTintColor      = self.navigationController.navigationBar.tintColor;
    _previousNavBarHidden         = self.navigationController.navigationBarHidden;
    _previousNavBarStyle          = self.navigationController.navigationBar.barStyle;
    _previousNavigationBarBackgroundImageDefault        = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    _previousNavigationBarBackgroundImageLandscapePhone = [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone];
}

- (void) restorePreviousNavBarAppearance:(BOOL)animated {
    
    if (_didSavePreviousStateOfNavBar) {
        
        [self.navigationController setNavigationBarHidden:_previousNavBarHidden animated:animated];
        UINavigationBar * navBar = self.navigationController.navigationBar;
        navBar.tintColor    = _previousNavBarTintColor;
        navBar.translucent  = _previousNavBarTranslucent;
        navBar.barTintColor = _previousNavBarBarTintColor;
        navBar.barStyle     = _previousNavBarStyle;
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageDefault forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:_previousNavigationBarBackgroundImageLandscapePhone forBarMetrics:UIBarMetricsLandscapePhone];
        // Restore back button if we need to
        if (_previousViewControllerBackButton) {
            
            UIViewController * previousViewController = [self.navigationController topViewController]; // We've disappeared so previous is now top
            previousViewController.navigationItem.backBarButtonItem = _previousViewControllerBackButton;
            _previousViewControllerBackButton = nil;
        }
    }
}

- (void) viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    CGSize sz = _pagingScrollView.bounds.size;
    if (sz.width != _befSize.width || sz.height != _befSize.height) {
        
        _befSize = sz;
        [self reloadData];
        [self layoutVisiblePages];
    }
}

- (void) layoutVisiblePages {
    
    // Flag
    _performingLayout = YES;
    
    // Remember index
    NSUInteger indexPriorToLayout = _browseData.currentIndex;
    
//    // Get paging scroll view frame to determine if anything needs changing
//    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
//
//    // Frame needs changing
//    if (!_skipNextPagingScrollViewPositioning) {
//        _pagingScrollView.frame = pagingScrollViewFrame;
//    }
    _skipNextPagingScrollViewPositioning = NO;
    
    // Recalculate contentSize based on current orientation
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    // Adjust frames and configuration of each visible page
    for (PhotoZoomingScrollView * page in _visiblePages) {
        
        NSUInteger index = page.index;
        page.frame = [self frameForPageAtIndex:index];
        
        // Adjust scales if bounds has changed since last time
        if (!CGRectEqualToRect(_previousLayoutBounds, self.view.bounds)) {
            // Update zooms for new bounds
            [page setMaxMinZoomScalesForCurrentBounds];
            _previousLayoutBounds = self.view.bounds;
        }
    }
    
    // Adjust contentOffset to preserve page location based on values collected prior to location
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
    [self didStartViewingPageAtIndex:_browseData.currentIndex]; // initial
    
    // Reset
    _browseData.currentIndex = indexPriorToLayout;
    _performingLayout = NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Remember page index before rotation
    _pageIndexBeforeRotation = _browseData.currentIndex;
    _rotating = YES;
    
    // In iOS 7 the nav bar gets shown after rotation, but might as well do this for everything!
    if ([self areControlsHidden]) {
        // Force hidden
        self.navigationController.navigationBarHidden = YES;
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Perform layout
    _browseData.currentIndex = _pageIndexBeforeRotation;
    
    // Delay control holding
    [self hideControlsAfterDelay];
    
    // Layout
    [self layoutVisiblePages];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    _rotating = NO;
    
    if ([self areControlsHidden]) {
        
        self.navigationController.navigationBarHidden = NO;
        self.navigationController.navigationBar.alpha = 0;
    }
}

- (void) reloadData {
    
    NSUInteger numberOfPhotos = [_browseData numberOfPhotos];
    
    // Update current page index
    if (numberOfPhotos > 0) {
        _browseData.currentIndex = MAX(0, MIN(_browseData.currentIndex, numberOfPhotos - 1));
    } else {
        _browseData.currentIndex = 0;
    }
    
    // Update layout
    if ([self isViewLoaded]) {
        
        while (_pagingScrollView.subviews.count) {
            [[_pagingScrollView.subviews lastObject] removeFromSuperview];
        }
        
        [self performLayout];
        [self.view setNeedsLayout];
    }
}

- (void) loadAdjacentPhotosIfNecessary:(id<MWPhoto>)photo {
    
    PhotoZoomingScrollView * page = [self pageDisplayingPhoto:photo];
    
    if (page) {
        
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = page.index;
        if (_browseData.currentIndex == pageIndex) {
            
            if (pageIndex > 0) {
                
                // Preload index - 1
                id <MWPhoto> photo = [_browseData photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                }
            }
            
            if (pageIndex < [_browseData numberOfPhotos] - 1) {
                
                // Preload index + 1
                id <MWPhoto> photo = [_browseData photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                }
            }
        }
    }
}

- (void) handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    
    id <MWPhoto> photo = [notification object];
    PhotoZoomingScrollView * page = [self pageDisplayingPhoto:photo];
    
    if (page) {
        
        if ([photo underlyingImage]) {
            
            // Successful load
            [page displayImage];
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            
            // Failed to load
            [page displayImageFailure];
        }
        
        // Update nav
        [self updateNavigation];
    }
}

- (void) tilePages {
    
    // Calculate which pages should be visible
    // Ignore padding as paging bounces encroach on that
    // and lead to false page loads
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger)floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex  = (NSInteger)floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [_browseData numberOfPhotos] - 1) iFirstIndex = [_browseData numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [_browseData numberOfPhotos] - 1) iLastIndex = [_browseData numberOfPhotos] - 1;
    
    // Recycle no longer needed pages
    NSInteger pageIndex;
    for (PhotoZoomingScrollView * page in _visiblePages) {
        
        pageIndex = page.index;
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            
            [_recycledPages addObject:page];
            [page prepareForReuse];
            [page removeFromSuperview];
        }
    }
    
    [_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    
    // Add missing pages
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        
        if (![self isDisplayingPageForIndex:index]) {
            
            // Add new page
            PhotoZoomingScrollView *page = [self dequeueRecycledPage];
            if (!page) {
                page = [[PhotoZoomingScrollView alloc] initWithPhotoBrowser:self];
            }
            [_visiblePages addObject:page];
            
            [self configurePage:page forIndex:index];
            
            [_pagingScrollView addSubview:page];
        }
    }
}

- (void) updateVisiblePageStates {
    
}

- (BOOL) isDisplayingPageForIndex:(NSUInteger)index {
    
    for (PhotoZoomingScrollView * page in _visiblePages) {
        
        if (page.index == index) return YES;
    }
    
    return NO;
}

- (PhotoZoomingScrollView *) pageDisplayedAtIndex:(NSUInteger)index {
    
    PhotoZoomingScrollView * thePage = nil;
    for (PhotoZoomingScrollView * page in _visiblePages) {
        
        if (page.index == index) {
            
            thePage = page;
            break;
        }
    }
    
    return thePage;
}

- (PhotoZoomingScrollView *) pageDisplayingPhoto:(id<MWPhoto>)photo {
    
    PhotoZoomingScrollView * thePage = nil;
    for (PhotoZoomingScrollView * page in _visiblePages) {
        
        if (page.photo == photo) {
            
            thePage = page;
            break;
        }
    }
    
    return thePage;
}

- (void) configurePage:(PhotoZoomingScrollView *)page forIndex:(NSUInteger)index {
    
    page.frame = [self frameForPageAtIndex:index];
    page.index = index;
    page.photo = [_browseData photoAtIndex:index];
}

- (PhotoZoomingScrollView *) dequeueRecycledPage {
    
    PhotoZoomingScrollView * page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    
    return page;
}

// Handle page changes
- (void) didStartViewingPageAtIndex:(NSUInteger)index {
    
    // Handle 0 photos
    if (![_browseData numberOfPhotos]) {
        // Show controls
        [self setControlsHidden:NO animated:YES permanent:YES];
        return;
    }
    
    // Release images further away than +/-1
    NSUInteger i;
    
    if (index > 0) {
        
        // Release anything < index - 1
        for (i = 0; i < index - 1; i++) {
            
            id photo = [_browseData.photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                
                [photo unloadUnderlyingImage];
                [_browseData.photos replaceObjectAtIndex:i withObject:[NSNull null]];
            }
        }
    }
    
    if (index < [_browseData numberOfPhotos] - 1) {
        
        // Release anything > index + 1
        for (i = index + 2; i < _browseData.photos.count; i++) {
            
            id photo = [_browseData.photos objectAtIndex:i];
            if (photo != [NSNull null]) {
                
                [photo unloadUnderlyingImage];
                [_browseData.photos replaceObjectAtIndex:i withObject:[NSNull null]];
            }
        }
    }
    
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    id <MWPhoto> currentPhoto = [_browseData photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    
    // Notify delegate
    if (index != _previousPageIndex) {
        
        if ([_delegate respondsToSelector:@selector(photoBrowser:didDisplayPhotoAtIndex:)])
            [_delegate photoBrowser:self didDisplayPhotoAtIndex:index];
        _previousPageIndex = index;
    }
    
    // Update nav
    [self updateNavigation];
}


- (CGRect) frameForPagingScrollView {
    
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return CGRectIntegral(frame);
}

- (CGRect) frameForPageAtIndex:(NSUInteger)index {
    
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}

- (CGSize) contentSizeForPagingScrollView {
    
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [_browseData numberOfPhotos], bounds.size.height);
}

- (CGPoint) contentOffsetForPageAtIndex:(NSUInteger)index {
    
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

#pragma mark - UIScrollView Delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // Checks
    if (!_viewIsActive || _performingLayout || _rotating) return;
    
    // Tile pages
    [self tilePages];
    
    // Calculate current page
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [_browseData numberOfPhotos] - 1) index = [_browseData numberOfPhotos] - 1;
    NSUInteger previousCurrentPage = _browseData.currentIndex;
    _browseData.currentIndex = index;
    if (_browseData.currentIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
    
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    // Hide controls when dragging begins
    [self setControlsHidden:YES animated:YES permanent:NO];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // Update nav when page changes
    [self updateNavigation];
}

- (void) jumpToPageAtIndex:(NSUInteger)index animated:(BOOL)animated {
    
    // Change page
    if (index < [_browseData numberOfPhotos]) {
        
        CGRect pageFrame = [self frameForPageAtIndex:index];
        [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:animated];
        [self updateNavigation];
    }
    
    // Update timer to give more time
    [self hideControlsAfterDelay];
}

- (void) gotoPreviousPage {
    
    [self showPreviousPhotoAnimated:NO];
}

- (void) gotoNextPage {
    
    [self showNextPhotoAnimated:NO];
}

- (void) showPreviousPhotoAnimated:(BOOL)animated {
    
    [self jumpToPageAtIndex:_browseData.currentIndex-1 animated:animated];
}

- (void) showNextPhotoAnimated:(BOOL)animated {
    
    [self jumpToPageAtIndex:_browseData.currentIndex+1 animated:animated];
}

- (void) setCurrentPhotoIndex:(NSUInteger)index {
    
    // Validate
    NSUInteger photoCount = [_browseData numberOfPhotos];
    if (photoCount == 0) {
        index = 0;
    } else {
        if (index >= photoCount)
            index = [_browseData numberOfPhotos]-1;
    }
    
    _browseData.currentIndex = index;
    if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index animated:NO];
        if (!_viewIsActive)
            [self tilePages]; // Force tiling if view is not visible
    }
}

// If permanent then we don't set timers to hide again
// Fades all controls on iOS 5 & 6, and iOS 7 controls slide and fade
- (void) setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    
    // Force visible
    if (![_browseData numberOfPhotos] || _alwaysShowControls)
        hidden = NO;
    
    // Cancel any timers
    [self cancelControlHiding];
    
    // Animations & positions
//    CGFloat animatonOffset = 20;
    CGFloat animationDuration = (animated ? 0.35 : 0);
    
    // Status bar
    if (!_leaveStatusBarAlone) {
        
        // Hide status bar
        if (!_isVCBasedStatusBarAppearance) {
            
            // Non-view controller based
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animated ? UIStatusBarAnimationSlide : UIStatusBarAnimationNone];
            
        } else {
            
            // View controller based so animate away
            _statusBarShouldBeHidden = hidden;
            [UIView animateWithDuration:animationDuration animations:^(void) {
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {}];
        }
    }
    
    // Toolbar, nav bar and captions
    // Pre-appear animation positions for sliding
    if ([self areControlsHidden] && !hidden && animated) {
        
        // Do something
    }
    
    [UIView animateWithDuration:animationDuration animations:^(void) {
        
        CGFloat alpha = hidden ? 0 : 1;
        
        // Nav bar slides up on it's own on iOS 7+
        [self.navigationController.navigationBar setAlpha:alpha];
        
    } completion:^(BOOL finished) {
        
        _controlsHidden = hidden;
    }];
    
    // Control hiding timer
    // Will cancel existing timer but only begin hiding if
    // they are visible
    if (!permanent) [self hideControlsAfterDelay];
    
}

- (BOOL) prefersStatusBarHidden {
    
    if (!_leaveStatusBarAlone) {
        return _statusBarShouldBeHidden;
    }
    
    return [self presentingViewControllerPrefersStatusBarHidden];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation) preferredStatusBarUpdateAnimation {
    
    return UIStatusBarAnimationSlide;
}

- (void) cancelControlHiding {
    
    // If a timer exists then cancel and release
    if (_controlVisibilityTimer) {
        
        [_controlVisibilityTimer invalidate];
        _controlVisibilityTimer = nil;
    }
}

// Enable/disable control visiblity timer
- (void) hideControlsAfterDelay {
    
    if (![self areControlsHidden]) {
        
        [self cancelControlHiding];
        _controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:self.delayToHideElements target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
    }
}

- (BOOL) areControlsHidden { return _controlsHidden; /*(_toolbar.alpha == 0);*/ }
- (void) hideControls { [self setControlsHidden:YES animated:YES permanent:NO]; }
- (void) showControls { [self setControlsHidden:NO animated:YES permanent:NO]; }
- (void) toggleControls { [self setControlsHidden:![self areControlsHidden] animated:YES permanent:NO]; }

- (void) updateNavigation {
    
    NSUInteger numberOfPhotos = [_browseData numberOfPhotos];
    
    // Buttons
    _btnPrev.enabled = _browseData.currentIndex > 0;
    _btnNext.enabled = _browseData.currentIndex < numberOfPhotos - 1;
    _txtRate.text    = [_browseData rateStringAtIndex:_browseData.currentIndex];
    
    if (_browseData.previousIndex != _browseData.currentIndex) {
        
        _browseData.previousIndex = _browseData.currentIndex;
        [appSetting() increaseMoveCnt];
    }
}

- (void) doneButtonPressed:(id)sender {
    
    // Only if we're modal and there's a done button
    if (_doneButton) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction) shareButtonPressed:(id)sender {
    
    // Only react when image has loaded
    id <MWPhoto> photo = [_browseData photoAtIndex:_browseData.currentIndex];
    
    if ([_browseData numberOfPhotos] > 0 && [photo underlyingImage]) {
        
        // Show activity view controller
        NSMutableArray * items = [NSMutableArray arrayWithObject:[photo underlyingImage]];
        if (photo.caption) {
            [items addObject:photo.caption];
        }
        self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        
        // Show
        typeof(self) __weak weakSelf = self;
        [self.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
            weakSelf.activityViewController = nil;
            [weakSelf hideControlsAfterDelay];
        }];
        
        // iOS 8 - Set the Anchor Point for the popover
        if (([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)) {
            
            CGRect frame = [_btnShare bounds];
            
            frame.size.height = self.view.frame.size.height;
            self.activityViewController.popoverPresentationController.sourceView = sender;
            self.activityViewController.popoverPresentationController.sourceRect = self.view.frame;
        }
        [self presentViewController:self.activityViewController animated:YES completion:nil];
        
        // Keep controls hidden
        [self setControlsHidden:NO animated:YES permanent:YES];
    }
}

- (IBAction) prevButtonPressed:(id)sender {
    
    if (_browseData.currentIndex == 0)
        return;
    
    [self jumpToPageAtIndex:_browseData.currentIndex - 1 animated:YES];
}

- (IBAction) nextButtonPressed:(id)sender {
    
    if (_browseData.currentIndex == [_browseData numberOfPhotos] - 1)
        return;
    
    [self jumpToPageAtIndex:_browseData.currentIndex + 1 animated:YES];
}

- (IBAction) likeButtonPressed:(id)sender {
    
    RD_Quote * quote = [_browseData.quoteList quoteAt:_browseData.currentIndex];
    
    [RequestService requestLike:appSetting().userId quoteId:quote.quoteId respondBlock:^(RD_Base *respond, NSError *error) {
        
        RD_Rate * result = (RD_Rate *) respond;
        
        if (result.result == RDResultSuccess) {
            
//            quote.rate = quote.rate + 1;
            quote.rate = result.rv;
            [self updateNavigation];
            
            [XToast showMessage:[NSString stringWithFormat:@"You made %d like", result.rv]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRateChangedNotification object:@[quote.quoteId, @(quote.rate)]];
            
            // refresh fav list
            AppDelegate * app = [AppDelegate sharedDelegate];
            [app.mainVC refreshList:3];
        }
    }];
}

- (IBAction) dislikeButtonPressed:(id)sender {
    
    RD_Quote * quote = [_browseData.quoteList quoteAt:_browseData.currentIndex];
    
    [RequestService requestDislike:appSetting().userId quoteId:quote.quoteId respondBlock:^(RD_Base *respond, NSError *error) {
        
        RD_Rate * result = (RD_Rate *) respond;
        
        if (result.result == RDResultSuccess) {
            
//            quote.rate = quote.rate - 1;
            quote.rate = result.rv;
            [self updateNavigation];
            
            [XToast showMessage:[NSString stringWithFormat:@"You made %d dislike", result.rv]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRateChangedNotification object:@[quote.quoteId, @(quote.rate)]];
            
            // refresh fav list
            AppDelegate * app = [AppDelegate sharedDelegate];
            [app.mainVC refreshList:3];
        }
    }];
}

- (IBAction) rateButtonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id353372460"]];
}

@end
