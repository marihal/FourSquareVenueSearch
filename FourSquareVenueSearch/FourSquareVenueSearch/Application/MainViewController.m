//
//  ViewController.m
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import "MainViewController.h"

#import "Config.h"
#import "LocationManager.h"
#import "Venue.h"
#import "VenueTableViewCell.h"

@import MapKit;

NSString* const kVenueCellIdentifier = @"VenueCell";

@interface MainViewController () {
    SearchRequest *_searchRequest;
    LocationManager *_locationManager;
}

@end

@implementation MainViewController

@synthesize searchResults = _searchResults;
@synthesize searchBar = _searchBar;
@synthesize spinner = _spinner;
@synthesize noResultsLabel = _noResultsLabel;
@synthesize resultsTable = _resultsTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchResults = [[NSMutableArray alloc] init];
    _locationManager = [LocationManager sharedLocationManager];
    
    // Change searchbar keyboard return button text from "Search" to "Done", as searching starts immediately when user types.
    for(UIView *subView in [_searchBar subviews]) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setReturnKeyType: UIReturnKeyDone];
        } else {
            for(UIView *subSubView in [subView subviews]) {
                if([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                    [(UITextField *)subSubView setReturnKeyType: UIReturnKeyDone];
                }
            }      
        }
    }
}

#pragma mark UISearchBarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length < 1) {
        // If search text is empty, show no results label
        [self showNoResults];
    } else {
        // Show spinner while waiting for search results
        [self showSpinner];
        
        // If another search request was already started, cancel it.
        if (_searchRequest) {
            [_searchRequest cancel];
            _searchResults = nil;
        }
        
        // Start a new search request
        _searchRequest = [[SearchRequest alloc] initWithKeyword:searchText
                                                    andLocation:[_locationManager locationStringWithDecimalCount:FOURSQUARE_EXPECTED_COORDINATE_DECIMAL_COUNT]];
        _searchRequest.delegate = self;
        [_searchRequest submit];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Hide search bar keyboard when "Done" is clicked
    [searchBar resignFirstResponder];
}

#pragma mark SearchRequestDelegate
-(void)venueSearchResults:(NSArray *)venues forSearch:(NSString *)searchText withError:(NSError *)error {
    // Show search results if search bar is still showing the text these search results are for
    // If the texts are not equal user has already initiated a search for something else and
    // we'll wait for those results
    if ([_searchBar.text isEqualToString:searchText]) {
        
        if (venues.count > 0) {
            // If results were found, sort the venues by distance and show the results in table view
            NSSortDescriptor *distanceDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
            NSArray *sortDescriptors = @[distanceDescriptor];
            _searchResults = [[venues sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
            
            [self showResults];
        } else {
            // If there were no results, empty results array and show no results label
            [_searchResults removeAllObjects];
            [self showNoResults];
        }
    }
}

#pragma mark UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VenueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVenueCellIdentifier];
    
    if (!cell) {
        cell = [[VenueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVenueCellIdentifier];
    }
    
    Venue *venue = _searchResults[indexPath.row];
    cell.nameLabel.text = venue.name;
    cell.addressLabel.text = venue.address;

    // Show distance only if it's bigger than 0. 0 usually means we didn't get any distance information, but
    // even for the case where we're already there it's no problem to just hide the distance.
    if (venue.distance > 0.0) {
        MKDistanceFormatter *formatter = [[MKDistanceFormatter alloc] init];
        formatter.units = MKDistanceFormatterUnitsMetric;
        cell.distanceLabel.text = [formatter stringFromDistance:venue.distance];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Hide search bar keyboard when user clicks a table view row
    [_searchBar resignFirstResponder];
    return indexPath;
}

-(void)showNoResults {
    // Make sure label showing is always done on main thread
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Hide table and spinner, show label
        [_spinner stopAnimating];
        _spinner.hidden = YES;
        _resultsTable.hidden = YES;
        _noResultsLabel.hidden = NO;
    });
}

-(void)showSpinner {
    // Make sure spinner showing is always done on main thread
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Hide label, show spinner. Leave table showing if it's already shown.
        _noResultsLabel.hidden = YES;
        [_spinner startAnimating];
        _spinner.hidden = NO;
    });
}

-(void)showResults {
    // Make sure table view showing is always done on main thread
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Hide label and spinner, show table
        _noResultsLabel.hidden = YES;
        [_spinner stopAnimating];
        _spinner.hidden = YES;
        _resultsTable.hidden = NO;
        [_resultsTable reloadData];
    });
}

@end
