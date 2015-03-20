//
//  SearchRequest.h
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocol for search request delegate that is called when search request is completed.
@protocol SearchRequestDelegate <NSObject>
-(void)venueSearchResults:(NSArray *)venues forSearch:(NSString *)searchText withError:(NSError *)error;
@end

@interface SearchRequest : NSObject

@property (retain) id<SearchRequestDelegate> delegate;

-(instancetype)initWithKeyword:(NSString *)keyword andLocation:(NSString *)location;

-(void)submit;

// Cancel this search request. The actual http request will only be cancelled if it's not yet started. If
// it has already been started, the handling of the results will be cancelled and delegate will not be notified.
-(void)cancel;

@end
