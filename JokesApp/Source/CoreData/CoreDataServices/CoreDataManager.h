//
//  CoreDataManager.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CacheEntity.h"

@interface CoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *          managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *            managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *    persistentStoreCoordinator;

/**
 * Get global CoreDataManager shared instance
 */
+ (CoreDataManager *) sharedInstance;


/**
 * Core Data Control functions
 *   Save CoreData, delete CoreData Model
 */
- (void) saveCoreData;
- (void) deleteObject:(NSManagedObject *)object;
- (id) newObjectEntity:(NSString *)entity;

+ (void) dispatchSyncBlockOnDataQueue:(dispatch_block_t)block;
+ (void) dispatchASyncBlockOnDataQueue:(dispatch_block_t)block;


/**
 * LocalUrl Entity Conroller functions
 */
- (CacheEntity *) newCacheEntityWithRemoteUrl:(NSString *)remoteUrl;
- (CacheEntity *) getCacheEntityWithRemoteUrl:(NSString *)remoteUrl;
- (NSArray *) getCacheEntities;

@end
