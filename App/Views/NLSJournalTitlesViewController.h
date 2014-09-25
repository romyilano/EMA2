//
//  NLSJournalTitlesViewController.h
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSTitleViewController.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"

@interface NLSJournalTitlesViewController : NLSTitleViewController

@property (readwrite, assign) NSUInteger section;
@property (strong, nonatomic) NSArray *letters;
@property (strong, nonatomic) NSString *journal;
@property (readwrite, assign) NSInteger journalId;

@end
