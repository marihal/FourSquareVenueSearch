//
//  Venue.h
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Venue : NSObject

@property NSString *name;
@property NSString *address;
@property CLLocationDistance distance;

@end
