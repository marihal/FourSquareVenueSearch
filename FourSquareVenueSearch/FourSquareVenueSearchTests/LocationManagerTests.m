//
//  LocationManagerTests.m
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import "LocationManager.h"

#import <XCTest/XCTest.h>

@interface LocationManagerTests : XCTestCase

@end

@implementation LocationManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetLocationString {
    LocationManager *locationManager = [LocationManager sharedLocationManager];
    NSString *location = [locationManager locationStringWithDecimalCount:1];
    XCTAssertNotNil(location, @"Location should not be nil");
    XCTAssertGreaterThan(location.length, 0, @"Location should not be empty.");
    NSArray *stringComponents = [location componentsSeparatedByString:@","];
    XCTAssertEqual(stringComponents.count, 2, @"Location string should have latitude and longitude separated by a comma (',').");
    XCTAssertGreaterThan(((NSString *)stringComponents[0]).length, 0, @"Latitude should not be empty.");
    XCTAssertGreaterThan(((NSString *)stringComponents[1]).length, 0, @"Longitude should not be empty.");
    XCTAssert(!([@"0" isEqualToString:stringComponents[0]] && [@"0" isEqualToString:stringComponents[1]]), @"Did not get proper location info: latitude and longitude are both 0");
}

- (void)testGetLocationStringWithNoDecimals {
    LocationManager *locationManager = [LocationManager sharedLocationManager];
    NSString *location = [locationManager locationStringWithDecimalCount:0];
    XCTAssertNotNil(location, @"Location should not be nil");
    XCTAssertGreaterThan(location.length, 0, @"Location should not be empty.");
    NSArray *stringComponents = [location componentsSeparatedByString:@","];
    XCTAssertEqual(stringComponents.count, 2, @"Location string should have latitude and longitude separated by a comma (',').");
    XCTAssertGreaterThan(((NSString *)stringComponents[0]).length, 0, @"Latitude should not be empty.");
    XCTAssertGreaterThan(((NSString *)stringComponents[1]).length, 0, @"Longitude should not be empty.");
    XCTAssert(!([@"0" isEqualToString:stringComponents[0]] && [@"0" isEqualToString:stringComponents[1]]), @"Did not get proper location info: latitude and longitude are both 0");
}

- (void)testGetLocationStringWithLotsOfDecimals {
    LocationManager *locationManager = [LocationManager sharedLocationManager];
    NSString *location = [locationManager locationStringWithDecimalCount:100];
    XCTAssertNotNil(location, @"Location should not be nil");
    XCTAssertGreaterThan(location.length, 0, @"Location should not be empty.");
    NSArray *stringComponents = [location componentsSeparatedByString:@","];
    XCTAssertEqual(stringComponents.count, 2, @"Location string should have latitude and longitude separated by a comma (',').");
    XCTAssertGreaterThan(((NSString *)stringComponents[0]).length, 0, @"Latitude should not be empty.");
    XCTAssertGreaterThan(((NSString *)stringComponents[1]).length, 0, @"Longitude should not be empty.");
    XCTAssert(!([@"0" isEqualToString:stringComponents[0]] && [@"0" isEqualToString:stringComponents[1]]), @"Did not get proper location info: latitude and longitude are both 0");
}

@end
