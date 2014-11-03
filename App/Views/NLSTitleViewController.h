//
//  NLSTitleViewController.h
//  App
//
//  Created by 4m1r on 7/23/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"
#import "PendingOperations.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"
#import "NLSUIKitExtras.h"
#import "NLSBaseTableViewController.h"
#import "EDColor.h"
#import "PBJActivityIndicator.h"
#import "SQLQuery.h"
#import "NLSSearchViewController.h"
#import "ILTranslucentView.h"
#import "NLSAutoSizeTextview.h"

#include "EMAConstants.h"


@interface NLSTitleViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, NSCacheDelegate, SQLQueryDelegate>

//table view
@property (strong, nonatomic) UITableView *tableView;

//search controller
@property (strong, nonatomic) UISearchController *searchController;
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableViewController *searchResultsController;

//props
@property (strong, nonatomic) NSString *defactoTitle;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *searchTitles;
@property (strong, nonatomic) NSMutableArray *cachePointer;
@property (strong, nonatomic) PendingOperations *pendingOperations;
@property (assign, atomic) BOOL isSearching;
@property (assign, atomic) BOOL searchReset;
@property (assign, atomic) NSInteger prevSearchRowCount;
@property (assign, atomic) NSInteger resultsCount;
@property (strong, nonatomic) NSIndexPath *lastIndex;
@property (strong, nonatomic) UIVisualEffectView *translucentView;

- (void)sqlQueryDidFinish:(SQLQuery *)query;
- (void)loadSearchBar;

@end
