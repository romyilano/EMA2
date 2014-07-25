//
//  NLSViewController.h
//  App
//
//  Created by Amir on 7/23/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"

@interface NLSViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NLSSQLAPI *sql;

@end
