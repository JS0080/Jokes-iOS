//
//  LocationUtil.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "LocationUtil.h"

LocationUtil * g_pLocationUtil = nil;

@interface LocationUtil () {
    
    NSMutableArray *        _delegates;
    
    CLLocationManager *     _locationManager;
    CLGeocoder *            _geoCoder;
    NSDate *                _lastUpdated;
    LocationUpdatedBlock    _updatedBlock;
}

@end

@implementation LocationUtil

#pragma mark - Initialization

+ (LocationUtil *)getInstance {
    
    if (g_pLocationUtil == nil) {
        g_pLocationUtil = [LocationUtil new];
    }
    
    return g_pLocationUtil;
}

- (instancetype) init {
    
    self = [super init];
    if (self) {
        
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    
    _delegates       = [[NSMutableArray alloc] init];
    _locationManager = [[CLLocationManager alloc] init];
    _geoCoder        = [[CLGeocoder alloc] init];
    
    self.updateInterval = 3600;
    self.location     = [XLocation locationUnknown];
    self.lastLocation = [XLocation locationUnknown];
    self.devLocation  = [XLocation locationUnknown];
    self.prevLocation = [XLocation locationUnknown];
}

#pragma mark - Delegate 

- (void)addDelegate:(id<LocationDelegate>)delegate {
    
//    if ([_delegates indexOfObject:delegate] >= _delegates.count)
        [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<LocationDelegate>)delegate {
    
    [_delegates removeObject:delegate];
}

#pragma mark - Location Manager

- (void)updateLocation {
    
    [self updateLocationWithBlock:^(XLocation *location) {
        
        [self postLocationResult:location];
    }];
}

- (void) updateLocationWithBlock:(LocationUpdatedBlock)block {
    
    _updatedBlock = block;
    
    //Store current location to prev
    if (_location.type != LocationTypeNone) {
        
        _prevLocation = _location;
    }
    
    //Respond for IOS 8
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [_locationManager requestWhenInUseAuthorization];
    
    //Start update location
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegation Helper

//Failed to update location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    //Stop current updating location
    [_locationManager stopUpdatingLocation];
    
    [self locationUpdated:[XLocation locationUnknown]];
    _updatedBlock = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //Stop current updating location
    [_locationManager stopUpdatingLocation];
    
    //Failed to update location
    if (locations == nil || locations.count <= 0) {
        
        [self locationUpdated:[XLocation locationUnknown]];
        _updatedBlock = nil;
        
        return;
    }
    
    CLLocation * location = [locations lastObject];
    
//    location = [[CLLocation alloc] initWithLatitude:41.80923804 longitude:123.40334036];
    
    _location = [XLocation locationWithLocation:location];
    
    //Get address from location
    [_geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        //Sussess to get address from location
        if (error == nil && [placemarks count] > 0) {
            
            CLPlacemark * placemark = [placemarks lastObject];
            
            _location = [XLocation locationWithPlacemark:placemark];
        }
        
        [self locationUpdated:_location];
        _updatedBlock = nil;
    }];
}

#pragma mark - Location Delegation

- (void) setLastLocation:(XLocation *)location {
    
    _lastLocation = location;
    _lastUpdated = [NSDate date];
}

- (void) locationUpdated:(XLocation *)location {
    
//    location.latitude = 43.371;
//    location.longitude = -80.980;
    _location = location;
    
    if (location.type != LocationTypeNone) {
        
        self.lastLocation = location;
    }
    
    if (_updatedBlock)
        _updatedBlock(location);
}

//Send Update Location Result
- (void) postLocationResult:(XLocation *)location {
    
    for (id<LocationDelegate> delegate in _delegates) {
        
        if ([delegate respondsToSelector:@selector(locationUtil:didUpdateWithLocation:)]) {
            
            [delegate locationUtil:self didUpdateWithLocation:location];
        }
    }
}

- (void) getLastLocationWithBlock:(LocationUpdatedBlock)block {
    
    if (_lastLocation.type == LocationTypeNone || [[NSDate date] timeIntervalSinceDate:_lastUpdated] > self.updateInterval) {
        
        [self updateLocationWithBlock:block];
    }
    else {
        
        block(_lastLocation);
    }
}

@end
