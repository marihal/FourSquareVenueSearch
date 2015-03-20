//
//  ViewController.h
//  FourSquareVenueSearch
//
//  Created by Mari Halkoaho on 17/03/15.
//  Copyright (c) 2015 Mari Halkoaho. All rights reserved.
//

#import "SearchRequest.h"

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchRequestDelegate>

@property (strong,nonatomic) NSMutableArray *searchResults;
@property IBOutlet UISearchBar *searchBar;
@property IBOutlet UIActivityIndicatorView *spinner;
@property IBOutlet UILabel *noResultsLabel;
@property IBOutlet UITableView *resultsTable;

@end