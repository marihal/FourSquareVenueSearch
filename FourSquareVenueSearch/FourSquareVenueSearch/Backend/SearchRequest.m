//
//  SearchRequest.m
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import "SearchRequest.h"

#import "Config.h"
#import "Venue.h"

@interface SearchRequest() {
    NSString *_keyword;
    NSString *_location;
    NSOperationQueue *_operationQueue;
    BOOL _cancelled;
}

@end

@implementation SearchRequest

-(instancetype)initWithKeyword:(NSString *)keyword andLocation:(NSString *)location {
    self = [super init];
    if (self) {
        _keyword = keyword;
        _location = location;
        _cancelled = NO;
    }
    
    return self;
}

-(NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return _operationQueue;
}

-(void)submit {
    // Format request url
    NSMutableString *requestUrl = [NSMutableString stringWithFormat:@"%@%@?client_id=%@&client_secret=%@&v=%@&m=%@",
                                                                    SERVER_URL,
                                                                    VENUE_SEARCH_ENDPOINT,
                                                                    FOURSQUARE_CLIENT_ID,
                                                                    FOURSQUARE_CLIENT_SECRET,
                                                                    FOURSQUARE_VERSION,
                                                                    FOURSQUARE_RESPONSE_STYLE];
    if (_keyword) {
        [requestUrl appendString:[NSString stringWithFormat:@"&query=%@",
                                                            [_keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    if (_location) {
        [requestUrl appendString:[NSString stringWithFormat:@"&ll=%@",
                                  [_location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    } else {
        // If location coordinates are not provided, show venues near Oulu, Finland. Either near or ll parameter must be
        // provided.
        [requestUrl appendString:[NSString stringWithFormat:@"&near=%@",
                                  [@"Oulu, Finland" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    // Create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestUrl]];
    [request setTimeoutInterval:30.0f];
    
    // Don't make the request if it should be cancelled.
    if (!_cancelled) {
        // Send http request asynchronously
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[self operationQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   // Don't handle results if request should be cancelled.
                                   if (!_cancelled) {
                                       if ([data length] > 0) {
                                           NSError *jsonError;
                                           
                                           // Get venue array from json data
                                           NSArray *venues = [self getVenuesFromJSON:jsonError data:data];
                                           
                                           // Send venues to delegate
                                           [_delegate venueSearchResults:venues forSearch:_keyword withError:error ? error : jsonError];
                                       } else {
                                           // If no data was received, send only error to delegate
                                           [_delegate venueSearchResults:nil forSearch:_keyword withError:error];
                                       }
                                   }
        }];
    }
}

-(void)cancel {
    _cancelled = YES;
    _delegate = nil;
}

- (NSArray *)getVenuesFromJSON:(NSError *)jsonError data:(NSData *)data {
    NSMutableArray *venues =  [NSMutableArray array];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    if (json) {
        // Go through venues in json and create a Venue instance for each
        NSDictionary *jsonResponse = [json objectForKey:@"response"];
        if (jsonResponse) {
            NSArray *jsonVenues = [jsonResponse objectForKey:@"venues"];
            for (NSDictionary *jsonVenue in jsonVenues) {
                Venue *venue = [[Venue alloc] init];
                
                // Set name of venue
                NSString *name = [jsonVenue objectForKey:@"name"];
                venue.name = name;
                
                // Get location info from json
                NSDictionary *location = [jsonVenue objectForKey:@"location"];
                if ([location count] > 0) {
                    
                    // If both address & city are known, format both into address, otherwise use the one that is available.
                    // If neither is available, address will remain nil.
                    NSString *address = [location objectForKey:@"address"];
                    NSString *city = [location objectForKey:@"city"];
                    if (address && city) {
                        venue.address = [NSString stringWithFormat:@"%@, %@", address, city];
                    } else if (address) {
                        venue.address = address;
                    } else {
                        venue.address = city;
                    }
                    
                    NSInteger distance = [[location objectForKey:@"distance"] integerValue];
                    venue.distance = distance;
                }
                
                [venues addObject:venue];
            }
        }
    }
    return venues;
}

@end
