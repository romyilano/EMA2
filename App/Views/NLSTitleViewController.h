//
//  NLSTitleViewController.h
//  App
//
//  Created by 4m1r on 7/23/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"
#import "NLSUIKitExtras.h"
#import "NLSBaseTableViewController.h"
#import "NLSQuery.h"
#import "NLSTMQuery.h"
#import "NLSSearchViewController.h"
#import "NLSAutoSizeTextview.h"
#import "NLSPendingOperations.h"
#import "EDColor.h"
#import "PBJActivityIndicator.h"
#import "NLSSettingsViewController.h"

#include "EMAConstants.h"


@interface NLSTitleViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, NSCacheDelegate, NLSQueryDelegate, NLSTMQueryDelegate>

//table view
@property (strong, nonatomic) UITableView *tableView;

//search controller
@property (strong, nonatomic) UISearchController *searchController;
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (assign, atomic) BOOL isSearching;
@property (assign, atomic) BOOL searchReset;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UITableViewController *searchResultsController;
@property (assign, atomic) NSInteger prevSearchRowCount;
@property (strong, nonatomic) NSMutableArray *searchTitles;

//props
@property (strong, nonatomic) NSString *defactoTitle;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *cachePointer;
@property (strong, nonatomic) NLSPendingOperations *pendingOperations;
@property (strong, nonatomic) NSNumber *titleCount;
@property (strong, nonatomic) NSNumber *resultsCount;
@property (strong, nonatomic) NSIndexPath *lastIndex;
@property (strong, nonatomic) UIVisualEffectView *translucentView;
@property (strong, nonatomic) NLSSettingsViewController *settings;


- (void)loadSearchBar;
- (void)loadTranslucentView;
- (void)fadeTranslucentView;
- (void)queryDidFinish:(NSInteger *)result;
- (void)sqlQueryDidFinish:(NLSTMQuery *)query;
- (void)suspendCells;
- (void)resumeCells;

@end
