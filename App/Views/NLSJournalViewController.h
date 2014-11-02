//
//  NLSJournalViewController.h
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"
#import "NLSTableViewCell.h"
#import "NLSJournalModel.h"
#import "NLSDetailViewController.h"
#import "NLSJournalTitlesViewController.h"
#import "EDColor.h"
#import "PBJActivityIndicator.h"
#import "NLSDescriptorViewController.h"

#include "EMAConstants.h"

@interface NLSJournalViewController : NLSDescriptorViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSArray *letters;

@end
