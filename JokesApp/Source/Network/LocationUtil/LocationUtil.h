//
//  LocationUtil.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "XLocation.h"

typedef void (^LocationUpdatedBlock)(XLocation * location);

@class LocationUtil;

@protocol LocationDelegate <NSObject>

@optional
- (void) locationUtil:(LocationUtil *)util didUpdateWithLocation:(XLocation *)location;

@end

@interface LocationUtil : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) XLocation *       location;
@property (nonatomic, retain) XLocation *       prevLocation;
@property (nonatomic, retain) XLocation *       lastLocation;
@property (nonatomic, retain) XLocation *       devLocation;
@property (nonatomic, assign) NSTimeInterval    updateInterval;

+ (LocationUtil *) getInstance;

- (void) addDelegate:(id<LocationDelegate>)delegate;
- (void) removeDelegate:(id<LocationDelegate>)delegate;

- (void) updateLocation;
- (void) updateLocationWithBlock:(LocationUpdatedBlock)block;

- (void) getLastLocationWithBlock:(LocationUpdatedBlock)block;

@end
