//
//  SearchRequestTests.m
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import "LocationManager.h"
#import "SearchRequest.h"

#import <XCTest/XCTest.h>

@interface SearchRequestTests : XCTestCase <SearchRequestDelegate> {
    dispatch_semaphore_t searchRequestSemaphore;
    NSArray *_venues;
    NSString *_searchedText;
    NSError *_error;
}

@end

@implementation SearchRequestTests

- (void)setUp {
    [super setUp];
    searchRequestSemaphore = dispatch_semaphore_create(0);
}

- (void)tearDown {
    [super tearDown];
}

-(void)venueSearchResults:(NSArray *)venues forSearch:(NSString *)searchText withError:(NSError *)error {
    XCTAssert([_searchedText isEqualToString:searchText], @"Received results for wrong search string.");
    _venues = venues;
    _error = error;
    
    // Let the waiting test know the response was received
    dispatch_semaphore_signal(searchRequestSemaphore);
}

- (void)testSearchRequestEmptySearchString {
    // Create search request and wait for the response
    _searchedText = [NSString string];
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithKeyword:_searchedText andLocation:nil];
    searchRequest.delegate = self;
    [searchRequest submit];
    dispatch_semaphore_wait(searchRequestSemaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertNil(_error, @"Search request error: %@", _error);
    XCTAssertNotNil(_venues, @"Venue array is nil");
    XCTAssertGreaterThan(_venues.count, 0, @"Empty venue array");
}

- (void)testSearchRequestBasicSearchString {
    // Create search request and wait for the response
    _searchedText = @"restaurant";
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithKeyword:_searchedText andLocation:nil];
    searchRequest.delegate = self;
    [searchRequest submit];
    dispatch_semaphore_wait(searchRequestSemaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertNil(_error, @"Search request error: %@", _error);
    XCTAssertNotNil(_venues, @"Venue array is nil");
    XCTAssertGreaterThan(_venues.count, 0, @"Empty venue array");
}

- (void)testSearchRequestUnicodeSearchString {
    // Create search request and wait for the response
    _searchedText = @"Nälkä";
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithKeyword:_searchedText andLocation:nil];
    searchRequest.delegate = self;
    [searchRequest submit];
    dispatch_semaphore_wait(searchRequestSemaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertNil(_error, @"Search request error: %@", _error);
    XCTAssertNotNil(_venues, @"Venue array is nil");
    // Let's not test how many venues we find, with this query we might not find any.
    // This test is just to see there is no error with this type of query.
}

- (void)testSearchRequestLongSearchString {
    // Create search request and wait for the response
    _searchedText = @"Where can I find food to eat?1234567890!°\"#€%&/()=?^*_:;>qwertyuiopåäölkjhgfdsa<zxcvbnm,.-";
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithKeyword:_searchedText andLocation:nil];
    searchRequest.delegate = self;
    [searchRequest submit];
    dispatch_semaphore_wait(searchRequestSemaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertNil(_error, @"Search request error: %@", _error);
    XCTAssertNotNil(_venues, @"Venue array is nil");
    // Let's not test how many venues we find, with this query we might not find any.
    // This test is just to see there is no error with this type of query.
}

- (void)testSearchRequestShortSearchString {
    // Create search request and wait for the response
    _searchedText = @"x";
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithKeyword:_searchedText andLocation:nil];
    searchRequest.delegate = self;
    [searchRequest submit];
    dispatch_semaphore_wait(searchRequestSemaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertNil(_error, @"Search request error: %@", _error);
    XCTAssertNotNil(_venues, @"Venue array is nil");
    XCTAssertGreaterThan(_venues.count, 0, @"Empty venue array");
}

- (void)testSearchRequestWithLocation {
    LocationManager *locationManager = [LocationManager sharedLocationManager];
    NSString *location = [locationManager locationStringWithDecimalCount:1];
    
    // Create search request and wait for the response
    _searchedText = [NSString string];
    SearchRequest *searchRequest = [[SearchRequest alloc] initWithKeyword:_searchedText andLocation:location];
    searchRequest.delegate = self;
    [searchRequest submit];
    dispatch_semaphore_wait(searchRequestSemaphore, DISPATCH_TIME_FOREVER);
    
    XCTAssertNil(_error, @"Search request error: %@", _error);
    XCTAssertNotNil(_venues, @"Venue array is nil");
    XCTAssertGreaterThan(_venues.count, 0, @"Empty venue array");
}

@end
