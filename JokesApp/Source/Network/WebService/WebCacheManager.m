//
//  WebCacheManager.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "WebCacheManager.h"
#import "CoreDataManager.h"
#import "CommonUtil.h"

#define kExpireDuration         (10 * 24 * 3600)

static inline NSString * cacheKeyFromURLRequest(NSURLRequest *request) {
    
    return [[request URL] absoluteString];
}

@implementation WebCacheManager

+ (WebCacheManager *) sharedInstance {
    
    static WebCacheManager * instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[WebCacheManager alloc] init];
    });
    
    return instance;
}

- (instancetype) init {
     
    self = [super init];
    if (self) {
        
        NSString * cacheDirectory = [[CommonUtil applicationDocumentsDirectory] stringByAppendingString:@"/cache/"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory])
            [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        [self expireCacheFromDb];
    }
    
    return self;
}

- (UIImage *) cachedImageForUrl:(NSString *)url {
    
    // first, check existing cached image
    UIImage * cachedImage = [self objectForKey:url];
    if (cachedImage)
        return cachedImage;
    
    // if not exist cached image, then check existing in database
    return [self getCacheImageFromDb:url];
}

- (UIImage *) cachedImageForRequest:(NSURLRequest *)request {
    
    switch ([request cachePolicy]) {
            
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
            
        default:
            break;
    }
    
    return [self cachedImageForUrl:cacheKeyFromURLRequest(request)];
}

- (void) cacheImage:(UIImage *)image forUrl:(NSString *)url {
    
    if (image && url) {
        
        [self setObject:image forKey:url];
        [self addCacheImageToDb:url image:image];
    }
}

- (void) cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
    
    if (image && request)
        [self cacheImage:image forUrl:cacheKeyFromURLRequest(request)];
}

#pragma mark - Cache Database

- (BOOL) addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    
    NSURL * URL = [NSURL fileURLWithPath: filePathString];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[URL path]])
        return NO;
    
    NSError * error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if (!success)
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    
    return success;
}

- (void) addCacheImageToDb:(NSString *)remoteUrl image:(UIImage *)image {
    
    [CoreDataManager dispatchSyncBlockOnDataQueue:^{
        
        CoreDataManager * data = [CoreDataManager sharedInstance];
        CacheEntity * cacheEntity = [data newCacheEntityWithRemoteUrl:remoteUrl];
        NSData * imageData = UIImagePNGRepresentation(image);
        NSString * local = [NSString stringWithFormat:@"%@%@", [CommonUtil applicationDocumentsDirectory], cacheEntity.cache_local_url];
        
        [imageData writeToFile:local atomically:YES];
        [self addSkipBackupAttributeToItemAtPath:local];
        
        cacheEntity.cache_timestamp = @([[NSDate date] timeIntervalSince1970]);
        
        [data saveCoreData];
    }];
}

- (UIImage *) getCacheImageFromDb:(NSString *)remoteUrl {
    
    __block UIImage * image = nil;
    
    [CoreDataManager dispatchSyncBlockOnDataQueue:^{
        
        CoreDataManager * data = [CoreDataManager sharedInstance];
        CacheEntity * cacheEntity = [data getCacheEntityWithRemoteUrl:remoteUrl];
        NSString * local = [NSString stringWithFormat:@"%@%@", [CommonUtil applicationDocumentsDirectory], cacheEntity.cache_local_url];
        
        if (cacheEntity != nil) {
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:local]) {
                
                [self deleteCacheEntity:cacheEntity coreData:data];
            }
            else {
                
                image = [UIImage imageWithData:[NSData dataWithContentsOfFile:local]];
                [self setObject:image forKey:remoteUrl];
            }
        }
    }];
    
    return image;
}
- (void) cleanCacheDb {
    
    [CoreDataManager dispatchSyncBlockOnDataQueue:^{
        
        CoreDataManager * data = [CoreDataManager sharedInstance];
        NSArray * cacheEntities = [data getCacheEntities];
        
        for (CacheEntity * entity in cacheEntities) {
            
            [self deleteCacheEntity:entity coreData:data];
        }
        
        [data saveCoreData];
    }];
}

- (void) deleteCacheEntity:(CacheEntity *)cacheEntity coreData:(CoreDataManager *)coreData {
    
    [[NSFileManager defaultManager] removeItemAtPath:cacheEntity.cache_local_url error:nil];
    [coreData deleteObject:cacheEntity];
}

- (void) deleteCacheFromDb:(NSString *)remoteUrl {
    
    [CoreDataManager dispatchSyncBlockOnDataQueue:^{
        
        CoreDataManager * data = [CoreDataManager sharedInstance];
        CacheEntity * cacheEntity = [data getCacheEntityWithRemoteUrl:remoteUrl];
        
        if (cacheEntity) {
            
            [self deleteCacheEntity:cacheEntity coreData:data];
            [data saveCoreData];
        }
    }];
}

- (void) expireCacheFromDb {
    
    [CoreDataManager dispatchSyncBlockOnDataQueue:^{
        
        CoreDataManager * data = [CoreDataManager sharedInstance];
        NSArray * cacheEntities = [data getCacheEntities];
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970] - kExpireDuration;
        
        for (CacheEntity * entity in cacheEntities) {
            
            if (entity.cache_timestamp.doubleValue < timestamp)
                [self deleteCacheEntity:entity coreData:data];
        }
        
        [data saveCoreData];
    }];
}

@end
