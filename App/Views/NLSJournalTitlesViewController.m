//
//  NLSJournalTitlesViewController.m
//  App
//
//  Created by Amir Djavaherian on 8/7/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSJournalTitlesViewController.h"

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
    self.defactoTitle = self.journal;
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

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)row WhereTitleMatch:str
{
    return [self.sql getTitleAndIdForRow:(NSInteger)row whereJournalEquals:self.journalId andTitleMatch:str];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)row
{
    return [self.sql getTitleAndIdForRow:(NSInteger)row whereJournalEquals:self.journalId];
}

-(NLSTitleModel*)createTitleForRow:(NSInteger)row
{
    
    __block NSInteger bRow = row;
    __block NSString *bString = self.searchBar.text;
    __block NSInteger bJournal = self.journalId;
    
    if (self.isSearching){
        NSLog(@"Using searchTitles cache with str: %@", bString);
        
        NLSTitleModel *tm = [[NLSTitleModel alloc] initWithCellId:bRow andSearchBarText:bString];
        tm.sqlQuery = ^{
            return [self.sql getTitleAndIdForRow:bRow whereJournalEquals:bJournal andTitleMatch:bString];
        };
        return tm;
    }else{
        NLSTitleModel *tm  = [[NLSTitleModel alloc] initWithCellId:bRow andSearchBarText:nil];
        tm.sqlQuery = ^{
            return [self.sql getTitleAndIdForRow:bRow whereJournalEquals:bJournal];
        };
        
        return tm;
    }
    
}


@end
