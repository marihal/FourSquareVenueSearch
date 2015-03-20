//
//  LocationManager.h
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

+(id)sharedLocationManager;

// Get current location as string
// @param decimals The desired number of decimals to show for latitude and longitude in the returned string.
// @return A string with latitude and longitude of current location, or nil if current location is not available.
-(NSString *)locationStringWithDecimalCount:(NSUInteger)decimals;

@end
