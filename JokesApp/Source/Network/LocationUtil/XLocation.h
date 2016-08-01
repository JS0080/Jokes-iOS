//
//  XLocation.h
//  SmoothPay2.0
//
//  Created by Alex on 11/12/15.
//  Copyright (c) 2015 BCL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    LocationTypeNone,
    LocationTypeLocation,
    LocationTypeGeocoder,
} LocationType;

@interface XLocation : NSObject <NSCopying>

@property (nonatomic, assign) CGFloat           latitude;
@property (nonatomic, assign) CGFloat           longitude;
@property (nonatomic, assign) LocationType      type;
@property (nonatomic, retain) NSString *        address;
@property (nonatomic, retain) CLLocation *      location;
@property (nonatomic, retain) NSString *        country;
@property (nonatomic, retain) NSString *        code;

+ (instancetype) locationUnknown;
+ (instancetype) locationWithLocation:(CLLocation *)location;
+ (instancetype) locationWithPlacemark:(CLPlacemark *)placemark;

- (id) copyWithZone:(NSZone *)zone;

@end
