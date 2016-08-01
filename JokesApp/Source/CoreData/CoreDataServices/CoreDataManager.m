//
//  CoreDataManager.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "CoreDataManager.h"
#import "CommonUtil.h"

#define kDatabaseName               @"jokesapp"
#define kDatabaseSQLiteName         @"jokesapp.sqlite"

#define t_cache_entity              @"CacheEntity"

#define f_cache_id                  @"cache_id"
#define f_cache_local_url           @"cache_local_url"
#define f_cache_remote_url          @"cache_remote_url"
#define f_cache_timestamp           @"cache_timestamp"

dispatch_queue_t dispatch_get_coredata_queue() {
    
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        queue = dispatch_queue_create("com.jokesapp.coredataqueue", nil);
    });
    
    return queue;
}

@implementation CoreDataManager

#pragma mark - initialization

+ (CoreDataManager *) sharedInstance {
    
    static CoreDataManager * _instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        _instance = [[CoreDataManager alloc] init];
    });
    
    return _instance;
}

- (id) init {
    
    self = [super init];
    
    if (self)
        [self setup];
    
    return self;
}

- (void) setup {
    
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:kDatabaseName withExtension:@"momd"];
    NSURL * storeURL = [[CommonUtil applicationDocumentsDirectoryURL] URLByAppendingPathComponent:kDatabaseSQLiteName];
    NSError * error = nil;
    NSDictionary * options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
    
    NSLog(@"CoreData Store Path : %@", storeURL.path);
    
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        
        NSLog(@"Deleted old database %@, %@", error, [error userInfo]);
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:@{NSMigratePersistentStoresAutomaticallyOption : @YES}
                                                          error:&error];
    }
    
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
}

#pragma mark - Core Data Database Control functions

- (void) saveCoreData {
    
    if (_managedObjectContext == nil || ![_managedObjectContext hasChanges])
        return;
    
    NSError * error = nil;
    [_managedObjectContext save:&error];
}

- (void) deleteObject:(NSManagedObject *)object {
    
    [_managedObjectContext deleteObject:object];
}

- (id) newObjectEntity:(NSString *)entity {
    
    return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:_managedObjectContext];
}

#pragma mark - Core Data Database functions

- (int) getMaxAttributeFromEntity:(NSString *)entityName attribute:(NSString *)attribute max:(BOOL)max {
    
    // Create fetch
    NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription * entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
    int maxAttr = 1;
    
    @try {
        
        [fetch setEntity:entity];
        [fetch setResultType:NSDictionaryResultType];
        
        // Expression for Max ID
        NSExpression * expAttr = [NSExpression expressionForKeyPath:attribute];
        NSExpression * expFunc = [NSExpression expressionForFunction:(max ? @"max:" : @"min:") arguments:@[expAttr]];
        NSExpressionDescription * expDesc = [[NSExpressionDescription alloc] init];
        
        [expDesc setName:@"maxAttr"];
        [expDesc setExpression:expFunc];
        [expDesc setExpressionResultType:NSInteger32AttributeType];
        [fetch setPropertiesToFetch:@[expDesc]];
        
        NSError * error = nil;
        NSArray * objects = nil;
        
        // Execute the fetch.
        objects = [_managedObjectContext executeFetchRequest:fetch error:&error];  // crashes here
        if (objects && objects.count > 0)
            maxAttr = [[[objects objectAtIndex:0] valueForKey:@"maxAttr"] intValue];
    }
    @catch (NSException *exception) {
    }
    
    return maxAttr;
}

- (NSArray *) fetchRequest:(NSString *)entityName format:(NSString *)format sort:(NSString *)sort ascending:(BOOL)ascending {
    
    NSEntityDescription * entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_managedObjectContext];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    NSError * error = nil;
    NSArray * results = nil;
    
    @try {
        
        [request setEntity:entity];
        
        if (format)
            [request setPredicate:[NSPredicate predicateWithFormat:format]];
        
        if (sort)
            [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:sort ascending:ascending]]];
        
        results = [_managedObjectContext executeFetchRequest:request error:&error];
    }
    @catch (NSException *exception) {
    }
    
    if (results == nil)
        results = [NSArray array];
    
    return results;
}

+ (void) dispatchSyncBlockOnDataQueue:(dispatch_block_t)block {
    
    static void * kKeyRunning = (void *) "core_running";
    void * running = dispatch_get_specific(kKeyRunning);
    
    if (running == kKeyRunning) {
        
        block();
    }
    else {
        
        dispatch_queue_t queue = dispatch_get_coredata_queue();
        
        dispatch_sync(queue, ^{
            
            dispatch_queue_set_specific(queue, kKeyRunning, kKeyRunning, NULL);
            block();
            dispatch_queue_set_specific(queue, kKeyRunning, NULL, NULL);
        });
    }
}

+ (void) dispatchASyncBlockOnDataQueue:(dispatch_block_t)block {
    
    dispatch_async(dispatch_get_coredata_queue(), block);
}

#pragma mark - LocalUrl Entity Controller

- (CacheEntity *) newCacheEntityWithRemoteUrl:(NSString *)remoteUrl {
    
    CacheEntity * cacheEntity = [self getCacheEntityWithRemoteUrl:remoteUrl];
    if (cacheEntity) return cacheEntity;
    
//    NSString * cacheDirectory = [[CommonUtil applicationDocumentsDirectory] stringByAppendingString:@"/cache/"];
    NSString * cacheDirectory = @"/cache/";
    
    cacheEntity = [self newObjectEntity:t_cache_entity];
    cacheEntity.cache_remote_url = remoteUrl;
    cacheEntity.cache_id = @([self getMaxAttributeFromEntity:t_cache_entity attribute:f_cache_id max:YES] + 1);
    cacheEntity.cache_local_url = [NSString stringWithFormat:@"%@image_%05d", cacheDirectory, cacheEntity.cache_id.intValue];
    
    return cacheEntity;
}

- (CacheEntity *) getCacheEntityWithRemoteUrl:(NSString *)remoteUrl {
    
    NSString * format = [NSString stringWithFormat:@"%@ = '%@'", f_cache_remote_url, remoteUrl];
    NSArray * results = [self fetchRequest:t_cache_entity format:format sort:nil ascending:YES];
    
    if (results.count > 0)
        return results[0];
    
    return nil;
}

- (NSArray *) getCacheEntities {
    
    return [self fetchRequest:t_cache_entity format:nil sort:nil ascending:NO];
}

@end
