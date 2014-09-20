//
//  NLSTitleViewController.h
//  App
//
//  Created by 4m1r on 7/23/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"
#include "EMAConstants.h"

@interface NLSTitleViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarController;
@property BOOL isSearching;
@property (strong, nonatomic) UIView *greenSub;

- (void) hideNavShadow;
- (UIImage*) imageWithColor:(UIColor*)color andHeight:(CGFloat)height;

@end
