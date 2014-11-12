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

- (void)loadView
{
    [super loadView];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seenSearchTut"];
}

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
    //get ref to prop
    NSInteger *journalId = self.journalId;
    
    // create a singature from the selector
    SEL selector = @selector(getTitleCountWhereJournalEquals:);
    NSMethodSignature *sig = [[self.sql class]instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&journalId atIndex:2];
    [invocation retainArguments];
    
    //create query and add to queue
    NLSQuery *nlsQuery = [[NLSQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:nlsQuery];
    
}

-(NSInteger)getTitleCountWhereTitleMatch
{
    
    //get ref to prop
    NSInteger *journalId = self.journalId;
    NSString *match = self.searchBar.text;
    
    // create a singature from the selector
    SEL selector = @selector(getTitleCountWhereJournalEquals:andTitleMatch:);
    NSMethodSignature *sig = [[self.sql class]instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&journalId atIndex:2];
    [invocation setArgument:&match atIndex:3];
    [invocation retainArguments];
    
    //create query and add to queue
    NLSQuery *nlsQuery = [[NLSQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:nlsQuery];
    
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
