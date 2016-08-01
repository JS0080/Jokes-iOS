//
//  ImageListViewController.m
//  JokesApp
//
//  Created by Michael Lee on 1/27/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "PhotoGridViewConroller.h"
#import "PhotoViewController.h"
#import "PhotoGridViewCell.h"
#import "PhotoBrowserData.h"
#import "RequestService.h"

@interface PhotoGridViewConroller () <UICollectionViewDataSource, UICollectionViewDelegate, PhotoBrowserDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *  indRefreshing;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *  indLoading;
@property (weak, nonatomic) IBOutlet UIView *                   barLoading;
@property (nonatomic, retain) PhotoViewController * photoBrowser;
@property (nonatomic, retain) PhotoBrowserData *    browseData;
@property (nonatomic, assign) CGFloat               margin;
@property (nonatomic, assign) CGFloat               gutter;
@property (nonatomic, assign) CGFloat               columns;
@property (nonatomic, assign) BOOL                  loading;
@property (nonatomic, assign) CGSize                befSize;

@end

@implementation PhotoGridViewConroller

- (void) updateView {
    
    _loading = NO;
    [_indLoading stopAnimating];
    [_barLoading setAlpha:0.0];
    
    if ([appSetting() refreshing:self.category]) {
        
        // loading
        [_indRefreshing startAnimating];
        [_gridView setHidden:YES];
    }
    else {
        
        // show list
        [_indRefreshing stopAnimating];
        [_gridView setHidden:NO];
    }
}

#pragma mark - Notification
- (void) startRefresh:(NSNotification *)notification {
    
    NSInteger category = [notification.object integerValue];
    
    if (category != self.category || !_indRefreshing)
        return;
    
    [self updateView];
    
    NSLog(@"StartRefresh Category %d", (int) category);
}

- (void) endRefresh:(NSNotification *)notification {
    
    NSInteger category = [notification.object integerValue];
    
    if (category != self.category || !_indRefreshing)
        return;
    
    [self updateView];
    
    [_browseData reloadData];
    [_gridView reloadData];
    
    if (_photoBrowser)
        [_photoBrowser reloadData];
    
    NSLog(@"EndRefresh Category %d", (int) category);
}

- (void) rateChanged:(NSNotification *)notification {
    
    NSArray * arr = notification.object;
    NSString * quoteId = [arr objectAtIndex:0];
    int rate = [[arr objectAtIndex:1] intValue];
    
    for (RD_Quote * quote in self.list.quoteList) {
        
        if ([quote.quoteId isEqualToString:quoteId]) {
            
            quote.rate = rate;
            break;
        }
    }
    
    [_gridView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    _photoBrowser = nil;
    
    [self updateView];
}

#pragma mark - Setup Appearance & Initialize
- (void) setupController {
    
    [super setupController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRefresh:) name:kStartRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh:) name:kEndRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rateChanged:) name:kRateChangedNotification object:nil];
    
    [self setupGridView];
}

#pragma mark - Loading
- (void) displayedItemAt:(NSUInteger)index {
    
    if (self.list.quoteCount >= self.list.totalCount || _loading)
        return;
    
    int rowCount = (int) (self.list.quoteCount + 2) / 3;
    int curRow   = (int) index / 3;
    
    if (curRow < rowCount - 1)
        return;
    
    int curPage = (int) self.list.quoteCount / kPageSize;
    
    _loading = YES;
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_indLoading startAnimating];
        [_barLoading setAlpha:1.0f];
    }];
    
#if 0 // for test
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2000000000), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.4 animations:^{
            
            [_indLoading stopAnimating];
            [_barLoading setAlpha:0.0f];
        }];
        
        RD_QuoteList * quote = [[RD_QuoteList alloc] init];
        NSMutableArray * list = [NSMutableArray array];
        for (int i = 0; i < 21; i ++) {
            
            RD_Quote * temp = [[RD_Quote alloc] init];
            
            temp.quoteId  = [NSString stringWithFormat:@"%d", (int) self.list.quoteCount + i];
            temp.quoteUrl = @"http://192.168.1.1/a.png";
            temp.rate     = self.list.quoteCount + i;
            
            [list addObject:temp];
        }
        
        quote.totalCount = 100;
        quote.totalPage  = 5;
        quote.page       = 0;
        quote.size       = 21;
        quote.quoteList  = list;
        
        [self.list appendQuoteList:quote];
        [_gridView reloadData];
        
        _loading = NO;
    });
#endif
    
    [RequestService requestList:self.category page:curPage size:kPageSize userId:appSetting().userId respondBlock:^(RD_Base *respond, NSError *error) {
        
        [UIView animateWithDuration:0.4 animations:^{
            
            [_indLoading stopAnimating];
            [_barLoading setAlpha:0.0f];
        }];

        RD_QuoteList * result = (RD_QuoteList *) respond;
        if (result.result == RDResultSuccess) {
            
            int curPage = (int) (self.list.quoteCount + kPageSize - 1) / kPageSize;
            
            if (curPage <= result.page) {
                
                [self.list appendQuoteList:result];
                [_gridView reloadData];
                
                if (_photoBrowser)
                    [_photoBrowser layoutVisiblePages];
            }
        }
    
        _loading = NO;
    }];
}

- (void) photoBrowser:(PhotoViewController *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    
    [self displayedItemAt:index];
}

#pragma mark - Grid View Controller 
- (RD_QuoteList *) list {
    
    return [appSetting() quoteList:self.category];
}

- (void) setupGridView {
    
    _columns = 3;
    _margin  = 2;
    _gutter  = 2;
    _initialContentOffset     = CGPointMake(0, CGFLOAT_MAX);
    
    _browseData = [[PhotoBrowserData alloc] init];
    _browseData.category = self.category;
    
    UINib * nib = [UINib nibWithNibName:@"PhotoGridViewCell" bundle:nil];
    [_gridView registerNib:nib forCellWithReuseIdentifier:@"PhotoGridViewCell"];
    
    _gridView.alwaysBounceVertical = YES;
    _gridView.backgroundColor      = [UIColor clearColor];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    NSArray * visibleCells = [_gridView visibleCells];
    if (visibleCells) {
        
        for (PhotoGridViewCell * cell in visibleCells) {
            
            [cell.photo cancelAnyLoading];
        }
    }
    
    [super viewWillDisappear:animated];
}

- (void) viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    [self performLayout];
    
    CGSize sz = _gridView.bounds.size;
    if (sz.width != _befSize.width || sz.height != _befSize.height) {
        
        _befSize = sz;
        [_gridView reloadData];
    }
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [_gridView reloadData];
    [self performLayout]; // needed for iOS 5 & 6
}

- (void) performLayout {
    
    _gridView.contentInset = UIEdgeInsetsMake(_gutter, 0, 0, 0);
}

- (void) adjustOffsetsAsRequired {
    
    // Move to previous content offset
    if (_initialContentOffset.y != CGFLOAT_MAX) {
        
        _gridView.contentOffset = _initialContentOffset;
        [_gridView layoutIfNeeded]; // Layout after content offset change
    }
    
    // Check if current item is visible and if not, make it so!
    if ([_browseData numberOfPhotos] > 0) {
        
        NSIndexPath * currentPhotoIndexPath = [NSIndexPath indexPathForItem:_browseData.currentIndex inSection:0];
        NSArray *     visibleIndexPaths     = [_gridView indexPathsForVisibleItems];
        BOOL          currentVisible = NO;
        
        for (NSIndexPath * indexPath in visibleIndexPaths) {
            
            if ([indexPath isEqual:currentPhotoIndexPath]) {
                
                currentVisible = YES;
                break;
            }
        }
        
        if (!currentVisible) {
            
            [_gridView scrollToItemAtIndexPath:currentPhotoIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }
}

- (NSInteger) collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    return [_browseData numberOfPhotos];
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoGridViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoGridViewCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[PhotoGridViewCell alloc] init];
    }
    
    cell.index        = indexPath.row;
    cell.photo        = [_browseData photoAtIndex:indexPath.row];
    cell.txtRate.text = [_browseData rateStringAtIndex:indexPath.row];
    
    UIImage * image = [_browseData imageForPhoto:cell.photo];
    
    if (image) {
        
        cell.imvPhoto.image = image;
    }
    else {
        
        cell.imvPhoto.image = [UIImage imageNamed:@"img_loading"];
        [cell.photo loadUnderlyingImageAndNotify];
    }
    
    [self displayedItemAt:indexPath.row];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _browseData.currentGridContentOffset = _gridView.contentOffset;
    _browseData.previousIndex = indexPath.row;
    
    _photoBrowser = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil];
    
    [_photoBrowser setDelegate:self];
    [_photoBrowser setBrowseData:_browseData];
    [_photoBrowser setCurrentPhotoIndex:indexPath.row];
    [self.navigationController pushViewController:_photoBrowser animated:YES];
    
    [appSetting() increaseMoveCnt];
}

- (void) collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoGridViewCell * gridCell = (PhotoGridViewCell *) cell;
    
    [gridCell.photo cancelAnyLoading];
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat value = floorf(((self.view.bounds.size.width - (_columns - 1) * _gutter - 2 * _margin) / _columns));
    return CGSizeMake(value, value);
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return _gutter;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return _gutter;
}

- (UIEdgeInsets) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(_margin, _margin, _margin, _margin);
}

@end
