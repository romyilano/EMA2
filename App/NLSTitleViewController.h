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

#import "GKCache.h"
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
@property (strong, nonatomic) UIView *greenSub;
@property (nonatomic, strong) GKCache *titles;
@property (nonatomic, strong) PendingOperations *pendingOperations;
@property (assign, atomic) BOOL isSearching;


- (void) hideNavShadow;
- (UIImage*) imageWithColor:(UIColor*)color andHeight:(CGFloat)height;
- (void)sqlQueryDidFinish:(SQLQuery *)query;

@end
