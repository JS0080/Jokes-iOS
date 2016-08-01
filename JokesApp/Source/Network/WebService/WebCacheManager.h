//
//  WebCacheManager.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WebCacheManager : NSCache

+ (WebCacheManager *) sharedInstance;

- (UIImage *) cachedImageForUrl:(NSString *)url;
- (UIImage *) cachedImageForRequest:(NSURLRequest *)request;

- (void) cacheImage:(UIImage *)image forUrl:(NSString *)url;
- (void) cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;

- (void) addCacheImageToDb:(NSString *)remoteUrl image:(UIImage *)image;
- (UIImage *) getCacheImageFromDb:(NSString *)remoteUrl;

- (void) cleanCacheDb;
- (void) deleteCacheFromDb:(NSString *)remoteUrl;
- (void) expireCacheFromDb;

@end
