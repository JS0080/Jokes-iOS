//
//  CacheEntity.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CacheEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * cache_id;
@property (nonatomic, retain) NSString * cache_local_url;
@property (nonatomic, retain) NSString * cache_remote_url;
@property (nonatomic, retain) NSNumber * cache_timestamp;

@end
