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

#import "EDColor.h"
#import "PBJActivityIndicator.h"
#import "SQLQuery.h"

#include "EMAConstants.h"


@interface NLSTitleViewController : UIViewController<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, NSCacheDelegate, SQLQueryDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarController;

@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *searchTitles;
@property (strong, nonatomic) NSMutableArray *cachePointer;
@property (strong, nonatomic) PendingOperations *pendingOperations;
@property (assign, atomic) BOOL isSearching;
@property (assign, atomic) BOOL searchReset;
@property (assign, atomic) NSInteger prevSearchRowCount;
@property (strong, nonatomic) NSIndexPath *lastIndex;


- (void)sqlQueryDidFinish:(SQLQuery *)query;

@end
