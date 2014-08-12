//
//  NLSTitleViewController.h
//  App
//
//  Created by 4m1r on 7/23/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"

@interface NLSTitleViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarController;
@property BOOL isSearching;

@end
