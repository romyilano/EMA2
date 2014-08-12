//
//  NLSFavoritesViewController.h
//  App
//
//  Created by Amir on 8/11/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"

@interface NLSFavoritesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NLSSQLAPI *sql;

@end
