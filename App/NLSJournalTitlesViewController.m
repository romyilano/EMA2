//
//  NLSJournalTitlesViewController.m
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSJournalTitlesViewController.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"

@interface NLSJournalTitlesViewController ()

@end

@implementation NLSJournalTitlesViewController

@synthesize section = _section;
@synthesize letters = _letters;
@synthesize journal = _journal;
@synthesize journalId = _journalId;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.journal;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SQL Overides

-(NSInteger)getTitleCount
{
    return (NSInteger)[self.sql getTitleCountWhereJournalEquals:self.journalId];
}

-(NSInteger)getTitleCountWhereTitleMatch
{
    return (NSInteger)[self.sql getTitleCountWhereJournalEquals:self.journalId andTitleMatch:self.searchBar.text];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)row WhereTitleMatch:str
{
    return [self.sql getTitleAndIdForRow:(NSUInteger)row whereJournalEquals:self.journalId andTitleMatch:str];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)row
{
    return [self.sql getTitleAndIdForRow:(NSUInteger)row whereJournalEquals:self.journalId];
}


@end
