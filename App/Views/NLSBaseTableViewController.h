//
//  NLSBaseTableViewController.h
//  App
//
//  Created by Amir on 10/28/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSTableViewCell.h"

@interface NLSBaseTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@end
