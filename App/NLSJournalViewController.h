//
//  NLSJournalViewController.h
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"

@interface NLSJournalViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSArray *letters;

@end
