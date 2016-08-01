//
//  XLocation.m
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import "XLocation.h"

@implementation XLocation

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.type = LocationTypeNone;
        self.address = NSLocalizedString(@"location.unknown", nil);
        self.location = nil;
        self.country = nil;
    }
    
    return self;
}

+ (instancetype)locationUnknown {
    
    return [[XLocation alloc] init];
}

+ (instancetype)locationWithLocation:(CLLocation *)location {
    
    XLocation * result = [[XLocation alloc] init];
    
    if (result) {
        
        result.latitude = location.coordinate.latitude;
        result.longitude = location.coordinate.longitude;
        result.address = [NSString stringWithFormat:@"lat : %.3f, lon : %.3f", result.latitude, result.longitude];
        result.type = LocationTypeLocation;
        result.location = location;
    }
    
    return result;
}

+ (instancetype)locationWithPlacemark:(CLPlacemark *)placemark {
    
    XLocation * result = [[XLocation alloc] init];
    
    if (result) {
        
        BOOL isEmpty = YES;
        
        result.latitude = placemark.location.coordinate.latitude;
        result.longitude = placemark.location.coordinate.longitude;
        result.type = LocationTypeGeocoder;
        result.address = @"";
        result.location = placemark.location;
        result.country = placemark.country;
        result.code = placemark.ISOcountryCode;
        
        if (placemark.subThoroughfare && ![placemark.subThoroughfare isEqualToString:@""]) {
            
            result.address = placemark.subThoroughfare;
            isEmpty = NO;
        }
        if (placemark.thoroughfare && ![placemark.thoroughfare isEqualToString:@""]) {
            
            result.address = isEmpty ? placemark.thoroughfare : [NSString stringWithFormat:@"%@ %@", result.address, placemark.thoroughfare];
            isEmpty = NO;
        }
        if (placemark.subAdministrativeArea && ![placemark.subAdministrativeArea isEqualToString:@""]) {
            
            result.address = isEmpty ? placemark.subAdministrativeArea : [NSString stringWithFormat:@"%@, %@", result.address, placemark.subAdministrativeArea];
            isEmpty = NO;
        }
        if (placemark.administrativeArea && ![placemark.administrativeArea isEqualToString:@""]) {
            
            result.address = isEmpty ? placemark.administrativeArea : [NSString stringWithFormat:@"%@, %@", result.address, placemark.administrativeArea];
            isEmpty = NO;
        }
        if (placemark.ISOcountryCode && ![placemark.ISOcountryCode isEqualToString:@""]) {
            
            result.address = isEmpty ? placemark.ISOcountryCode : [NSString stringWithFormat:@"%@, %@", result.address, placemark.ISOcountryCode];
            isEmpty = NO;
        }
        if (isEmpty) {
            
            return [XLocation locationWithLocation:placemark.location];
        }
    }
    
    return result;
}

- (id)copyWithZone:(NSZone *)zone {
    
    XLocation * result = [[XLocation alloc] init];
    
    result.latitude = self.latitude;
    result.longitude = self.longitude;
    result.type = self.type;
    result.address = self.address;
    result.location = self.location;
    result.country = self.country;
    
    return result;
}

@end
