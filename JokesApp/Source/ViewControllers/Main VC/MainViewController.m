//
//  MainViewController.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoGridViewConroller.h"
#import "RequestService.h"
#import "RD_QuoteList.h"
#import "RD_Admob.h"
#import "XToast.h"

@interface MainViewController () <XPageDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *   csTabIndLeading;
@property (weak, nonatomic) IBOutlet UIView *               pageContainer;
@property (weak, nonatomic) IBOutlet UIButton *             btnRefresh;

@property (nonatomic, retain) XPageManager *                pageManager;
@property (nonatomic, retain) NSArray *                     arrPage;
@property (nonatomic, retain) NSArray *                     arrButton;
@property (nonatomic, assign) BOOL                          animating;
@property (nonatomic, assign) BOOL                          initialized;

@end

@implementation MainViewController

- (IBAction) onBtnTabTapped:(id)sender {
    
    NSInteger index = [_arrButton indexOfObject:sender];
    
    if (_pageManager.selectedIndex == index/* || _animating*/)
        return;
    
    [_pageManager setSelectedIndex:index];
    [self updateTabStateWithAnimate:index];
}

- (IBAction) onBtnRefreshTapped:(id)sender {
    
    [self refreshListAll];
}

- (void) updateTabStateWithAnimate:(NSInteger)index {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3f animations:^{
            
            _animating = YES;
            
            [self updateTabState:index];
        } completion:^(BOOL finished) {
            
            _animating = NO;
        }];
    });
}

- (void) updateTabState:(NSInteger)tab {
    
//    for (int i = 0; i < _arrButton.count; i ++) {
//        
//        UIButton * btn = _arrButton[i];
//        
//        if (i == tab)
//            [btn setTitleColor:[UIColor textColorWithCustomizeType:DinoAccountTabActive] forState:UIControlStateNormal];
//        else
//            [btn setTitleColor:[UIColor textColorWithCustomizeType:DinoAccountTabInactive] forState:UIControlStateNormal];
//    }
    
    UIButton * btn = (UIButton *) [_arrButton objectAtIndex:0];
    _csTabIndLeading.constant = tab * btn.frame.size.width;
    
    [self.view layoutIfNeeded];
}

- (void) orientationChanged:(NSNotification *)notification{
    
    [self updateTabState:_pageManager.selectedIndex];
}

- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if (_btnRefresh.frame.size.width < 100)
        [_btnRefresh setTitle:@"" forState:UIControlStateNormal];
    else
        [_btnRefresh setTitle:@"Refresh" forState:UIControlStateNormal];
}

#pragma mark - Page Manager Delegation
#pragma mark -
- (void) pageManager:(XPageManager *)pageManager willTransitionToPage:(NSInteger)toPage fromPage:(NSInteger)fromPage {
    
//    [self updateTabStateWithAnimate:toPage];
}

- (void) pageManager:(XPageManager *)pageManager didTransitionToPage:(NSInteger)toPage fromPage:(NSInteger)fromPage {
    
    [self updateTabStateWithAnimate:toPage];
    
    NSDate * date = [NSDate date];
    NSTimeInterval elapse = [date timeIntervalSinceDate:appSetting().refreshTime];
    
    // elapsed 3 minutes
    if (elapse >= 3 * 60) {
        
        [self refreshListAll];
    }
}

#pragma mark - Refresh Image List
- (void) refreshList:(NSInteger)category {
    
#if 0 // for test
    RD_QuoteList * quote = [[RD_QuoteList alloc] init];
    NSMutableArray * list = [NSMutableArray array];
    for (int i = 0; i < 21; i ++) {
        
        RD_Quote * temp = [[RD_Quote alloc] init];
        
        temp.quoteId  = [NSString stringWithFormat:@"%d", i];
        temp.quoteUrl = @"http://192.168.1.1/a.png";
        temp.rate     = i;
        
        [list addObject:temp];
    }
    
    quote.totalCount = 100;
    quote.totalPage  = 5;
    quote.page       = 0;
    quote.size       = 21;
    quote.quoteList  = list;
    
    [appSetting() setQuoteList:quote category:category];
    return;
#endif
    
    [appSetting() setRefreshing:YES category:category];
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartRefreshNotification object:@(category)];
    
    [RequestService requestList:category page:0 size:kPageSize userId:appSetting().userId respondBlock:^(RD_Base *respond, NSError *error) {
        
        RD_QuoteList * result = (RD_QuoteList *) respond;
        
        if (result.result == RDResultSuccess) {
            
            [appSetting() setQuoteList:result category:category];
        }
        
        [appSetting() setRefreshing:NO category:category];
        [[NSNotificationCenter defaultCenter] postNotificationName:kEndRefreshNotification object:@(category)];
    }];
}

- (void) refreshListAll {
    
    [self checkConnection:_initialized];
    
    appSetting().refreshTime = [NSDate date];
    
    for (int i = 0; i < 4; i ++) {
        
        [self refreshList:i];
    }
    
    [RequestService requestAdmob:^(RD_Base *respond, NSError *error) {
        
        RD_Admob * admob = (RD_Admob *) respond;
        
        if (admob.result == RDResultSuccess) {
            
            appSetting().useAdmob = admob.useAdmob;
            appSetting().admobType = admob.admobType;
            appSetting().admobInterval = admob.admobInterval;
        }
        
        [appSetting() createAndLoadInterstitial];
    }];
}

- (BOOL) checkConnection:(BOOL)showMsg {
    
    if ([CommonUtil isInternetConnected] == NO) {
        
        if (showMsg)
            [XToast showMessage:[NSString stringWithFormat:@"No connection is detected"]];
        
        return NO;
    }
    
    return YES;
}

- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (_initialized == NO) {
        
        _initialized = YES;
        [self checkConnection:YES];
    }
}

#pragma mark - Layout & Appearance Setting
#pragma mark -
- (void) setupController {
    
    [super setupController];
    
    _initialized = NO;
    
    NSMutableArray * arrBtn = [NSMutableArray array];
    for (int i = 0; i < 4; i ++) {
        
        UIButton * btn = (UIButton *) [self.view viewWithTag:(i + 1)];
        [arrBtn addObject:btn];
    }
    
    NSMutableArray * arrPage = [NSMutableArray array];
    for (int i = 0; i < 4; i ++) {
        
        PhotoGridViewConroller * vc = [PhotoGridViewConroller newInstance];
        vc.category = i;
        [arrPage addObject:vc];
    }
    
    _arrButton   = [NSArray arrayWithArray:arrBtn];
    _arrPage     = [NSArray arrayWithArray:arrPage];
    _pageManager = [[XPageManager alloc] initWithParentViewController:self containerView:_pageContainer viewControllers:_arrPage];
    
    [_pageManager setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void) setupAppearance {
    
    [super setupAppearance];
}

@end
