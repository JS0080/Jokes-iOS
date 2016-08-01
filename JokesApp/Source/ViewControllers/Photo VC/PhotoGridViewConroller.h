//
//  ImageListViewController.h
//  JokesApp
//
//  Created by Michael Lee on 1/27/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "XPageItemViewController.h"

@class PhotoViewController;

@interface PhotoGridViewConroller : XPageItemViewController

@property (weak, nonatomic) IBOutlet UICollectionView * gridView;

@property (nonatomic, assign) NSInteger             category;
@property (nonatomic, assign) CGPoint               initialContentOffset;

- (void) displayedItemAt:(NSUInteger)index;

@end
