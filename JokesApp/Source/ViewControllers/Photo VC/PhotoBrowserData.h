//
//  PhotoBrowserData.h
//  JokesApp
//
//  Created by Michael Lee on 1/30/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RD_QuoteList.h"

@interface PhotoBrowserData : NSObject

@property (nonatomic, assign) NSUInteger        category;
@property (nonatomic, assign) NSUInteger        currentIndex;
@property (nonatomic, assign) NSUInteger        previousIndex;
@property (nonatomic, assign) CGPoint           currentGridContentOffset;
@property (nonatomic, readonly) RD_QuoteList *  quoteList;
@property (nonatomic, retain) NSMutableArray *  photos;
@property (nonatomic, retain) UIColor *         backColor;

- (NSUInteger)  numberOfPhotos;
- (id<MWPhoto>) photoAtIndex:(NSUInteger)index;
- (UIImage *)   imageForPhoto:(id<MWPhoto>)photo;
- (NSString *)  rateStringAtIndex:(NSUInteger)index;

- (void) releaseAllUnderlyingPhotos:(BOOL)preserveCurrent;

- (void) reloadData;

@end
