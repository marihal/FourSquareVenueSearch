//
//  LocationManager.m
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager() {
    CLLocationManager *_locationManager;
    BOOL _updatingLocations;
}

@end

@implementation LocationManager

+ (id)sharedLocationManager {
    static LocationManager *sharedLocationManager = nil;
    @synchronized(self) {
        if (sharedLocationManager == nil)
            sharedLocationManager = [[self alloc] init];
    }
    return sharedLocationManager;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _updatingLocations = NO;
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        // Set a movement threshold for new events.
        _locationManager.distanceFilter = 100; // meters
        
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
        if (_locationManager.location && CLLocationCoordinate2DIsValid(_locationManager.location.coordinate)) {
            _updatingLocations = YES;
        }
    }
    return self;
}

-(NSString *)locationStringWithDecimalCount:(NSUInteger)decimals {
    @synchronized(self) {
        if (_updatingLocations) {
            if (_locationManager.location != nil && CLLocationCoordinate2DIsValid(_locationManager.location.coordinate)) {
                return [self formatStringForLocation:_locationManager.location.coordinate withDecimals:decimals];
            }
        }
    }
    // Return nil if no valid location available
    return nil;
}

- (NSString *)formatStringForLocation:(CLLocationCoordinate2D)location withDecimals:(NSUInteger)decimals {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.minimumFractionDigits = decimals;
    formatter.maximumFractionDigits = decimals;
    
    return [NSString stringWithFormat:@"%@,%@",
            [formatter stringFromNumber:@(location.latitude)],
            [formatter stringFromNumber:@(location.longitude)]];
}

#pragma mark CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    @synchronized(self) {
        _updatingLocations = YES;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Unable to get location. Error: %@", error.description);
    // When unable to get location because of lacking authorization, stop getting location updates until authorization status changes.
    if (error.code == kCLErrorDenied) {
        @synchronized(self) {
            [_locationManager stopUpdatingLocation];
            _updatingLocations = NO;
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    @synchronized(self) {
        // If user gives authorization to location services, start updating location.
        if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            _updatingLocations = YES;
            [_locationManager startUpdatingLocation];
        } else {
            // If authorization is taken away, stop updating location.
            _updatingLocations = NO;
            [_locationManager stopUpdatingLocation];
        }
    }
}

@end
