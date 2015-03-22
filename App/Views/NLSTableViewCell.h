//
//  NLSTableViewCell.h
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Colleen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSTitleModel.h"
#import "EDColor.h"
#import "EMAConstants.h"
#import "NLSTMQuery.h"
#import "NLSDescriptorArrayQuery.h"
#import "NLSJournalQuery.h"
#import "NLSPendingOperations.h"
#import "NLSSQLAPI.h"

@interface NLSTableViewCell : UITableViewCell<NSCacheDelegate, NLSTMQueryDelegate, NLSDescriptorArrayQueryDelegate, NLSJournalQueryDelegate>

@property (readwrite, nonatomic) NSInteger rowId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NLSTitleModel *tm;
@property (readwrite, assign) BOOL isSearching;
@property (strong, nonatomic) NLSPendingOperations *pendingOperations;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSString *searchText;
@property (readwrite, nonatomic, copy) NSString *title;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *journalLabel;
@property (strong, nonatomic) UILabel *descriptorLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath*)indexPath;
-(void)updateCellWithTitleModel:(NLSTitleModel*)tm;
-(void)updateCellWithDescriptors:(NLSTitleModel *)tm;
-(void)updateCellWithJournal:(NLSTitleModel *)tm;
-(void)sqlQueryDidFinish:(NLSTMQuery *)query;
-(void)journalQueryDidFinish:(NLSJournalQuery *)query;
-(void)sqlQueryDidFinishForMeshArray:(NLSDescriptorArrayQuery *)query;
-(void)startQuery:(SEL)selector;
-(void)startDescriptorQuery:(SEL)selector;
-(NSSet *)propertyNames;
-(void)reloadView;
@end
