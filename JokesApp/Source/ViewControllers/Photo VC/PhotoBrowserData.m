//
//  PhotoBrowserData.m
//  JokesApp
//
//  Created by Michael Lee on 1/30/16.
//  Copyright © 2016 Michael Lee. All rights reserved.
//

#import "PhotoBrowserData.h"
#import "AppSetting.h"

@interface PhotoBrowserData ()

@end

@implementation PhotoBrowserData

- (instancetype)init {
    
    if (self = [super init]) {
        
        [self _initialization];
    }
    
    return self;
}

- (void) _initialization {
    
    _currentIndex             = 0;
    _currentGridContentOffset = CGPointMake(0, CGFLOAT_MAX);
    _photos                   = [[NSMutableArray alloc] init];
    _backColor                = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
}

- (RD_QuoteList *) quoteList {
    
    return [appSetting() quoteList:self.category];
}

- (void) releaseAllUnderlyingPhotos:(BOOL)preserveCurrent {
    
    // Create a copy in case this array is modified while we are looping through
    // Release photos
    NSArray * copy = [_photos copy];
    for (id p in copy) {
        if (p != [NSNull null]) {
            if (preserveCurrent && p == [self photoAtIndex:self.currentIndex]) {
                continue; // skip current
            }
            [p unloadUnderlyingImage];
        }
    }
}

- (NSUInteger) numberOfPhotos {
    
    return self.quoteList.quoteCount;
}

- (void) matchPhotos {
    
    NSUInteger numPhotos = [self numberOfPhotos];
    
    if (_photos.count < numPhotos) {
        
        for (NSUInteger i = _photos.count; i < numPhotos; i ++) {
            
            [_photos addObject:[NSNull null]];
        }
    }
}

- (id<MWPhoto>) photoAtIndex:(NSUInteger)index {
    
    [self matchPhotos];
    
    id <MWPhoto> photo = nil;
    
    if (index < _photos.count) {
        
        if ([_photos objectAtIndex:index] == [NSNull null]) {
            
            photo = [MWPhoto photoWithURL:[self.quoteList quoteUrlAt:index]];
            [_photos replaceObjectAtIndex:index withObject:photo];
        }
        else {
            
            photo = [_photos objectAtIndex:index];
        }
    }
    
    return photo;
}

- (UIImage *) imageForPhoto:(id<MWPhoto>)photo {
    
    if (photo) {
        
        // Get image or obtain in background
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
        }
    }
    
    return nil;
}

- (NSString *) rateStringAtIndex:(NSUInteger)index {
    
    RD_Quote * quote = [self.quoteList quoteAt:index];
    
    if (quote.rate == 0)
        return @" 0 ";
    else if (quote.rate > 0)
        return [NSString stringWithFormat:@" +%d ", (int) quote.rate];
    
    return [NSString stringWithFormat:@" %d ", (int) quote.rate];
}

- (void) reloadData {
    
    [self releaseAllUnderlyingPhotos:YES];
    [_photos removeAllObjects];
    [self matchPhotos];
}

@end
