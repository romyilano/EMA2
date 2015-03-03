//
//  NLSTableViewCell.h
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSTitleModel.h"
#import "EDColor.h"
#import "EMAConstants.h"
#import "NLSTMQuery.h"
#import "NLSPendingOperations.h"
#import "NLSSQLAPI.h"

@interface NLSTableViewCell : UITableViewCell<NSCacheDelegate, NLSTMQueryDelegate>

@property (readwrite, assign) NSInteger rowId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NLSTitleModel *tm;
@property (readwrite, assign) BOOL isSearching;
@property (strong, nonatomic) NLSPendingOperations *pendingOperations;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSString *searchText;

-(void)updateCellWithTitleModel:(NLSTitleModel*)tm atIndexPath:(NSIndexPath *)indexPath;
-(void)startQueryWithIndexPath:(NSIndexPath *)indexPath;
@end
