//
//  NLSDescriptorViewController.h
//  App
//
//  Created by Amir on 8/6/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"
#import "NLSDetailViewController.h"
#import "NLSDescriptorTitlesViewController.h"
#import "PBJActivityIndicator.h"
#import "EDColor.h"
#import "NLSTableView.h"
#import "NLSTitleViewController.h"

@interface NLSDescriptorViewController : NLSTitleViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIScrollViewDelegate>

@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSArray *letters;
@property (strong, nonatomic) NLSTableView *tableView;
@property (strong, nonatomic) NSString *defactoTitle;

//search controller
@property (assign, atomic) BOOL isSearching;
@property (strong, nonatomic) UISearchController *searchController;
//@property BOOL searchControllerWasActive;
//@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableViewController *searchResultsController;


@end
