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
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seenSearchTut"];
    self.title = self.journal;
    self.defactoTitle = self.journal;
    [self primeTitleCache];
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

-(void)primeTitleCache
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // get ref to prop
    NSInteger *journalId = self.journalId;
    
    // temp result set
    NSMutableArray *tempResultSet;
    
    // create a signature from the selector
    SEL selector = @selector(getTitleModelsWhereJournalEquals:);
    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    // setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&journalId atIndex:2];
    [invocation retainArguments];
    
    //create query and add to queue
    NLSTMArrayQuery *nlsTMArrayQuery = [[NLSTMArrayQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:nlsTMArrayQuery];
    
}

-(void)primeTitleCacheWithMatch:(NSString*)match
{
    NSInvocation *invocation = nil;
    NSMutableArray *tempResultSet;
    
    // get ref to prop
    NSInteger *journalId = self.journalId;
    
    // create a signature from the selector
    SEL selector = @selector(getTitleModelsWhereJournalEquals:andTitleMatch:);
    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    //setup invocation and args
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&journalId atIndex:2];
    [invocation setArgument:&match atIndex:3];
    [invocation retainArguments];
    
    //create query and add to queue
    NLSTMArrayQuery *nlsTMArrayQuery = [[NLSTMArrayQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:nlsTMArrayQuery];
    
}

//- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCellIdentifier"];
//    NSInteger rowAtIndex = indexPath.row;
//    
//    if (self.isSearching){
//        
//        if ([self.cachePointer count] >> 0){
//            NSLog(@"indexPath.row %ld >> cachePointer.count: %ld", indexPath.row, [self.cachePointer count] );
//            rowAtIndex = [[self.cachePointer objectAtIndex:indexPath.row] integerValue];
//        } else {
//            rowAtIndex = 1;
//        }
//        
//        if (!cell) {
//            NSLog(@"no cell, is searching pulling row %ld", rowAtIndex);
//            cell = [[NLSTableViewCell alloc]
//                    initWithStyle:UITableViewCellStyleDefault
//                    reuseIdentifierDefault:@"TitleCellIdentifier"];
//            
//        } else {
//            NSLog(@"re-using cell at indexPath %ld, pulling %ld", indexPath.row, rowAtIndex);
//            if ([self.cachePointer count] >= 1){
//                NSLog(@"have stuff in search cache %ld", rowAtIndex);
//                [cell updateCellWithId:rowAtIndex];
//            }
//            
//        }
//        
//    } else {
//        
//        if (!cell) {
//            NSLog(@"no cell, no search");
//            cell = [[NLSTableViewCell alloc]
//                    initWithStyle:UITableViewCellStyleDefault
//                    reuseIdentifierDefault:@"TitleCellIdentifier"];
//        } else {
//            rowAtIndex = [[self.cachePointer objectAtIndex:indexPath.row] integerValue];
//            NSLog(@"no search re-using cell at indexPath %ld, pulling %ld", indexPath.row, rowAtIndex);
//            [cell updateCellWithId:rowAtIndex];
//        }
//    }
//    
//    return cell;
//}

//- (void)startQueryForIndexPath:(NSIndexPath *)indexPath
//{
////    NSMutableArray *queriesInProgress = nil;
//    NLSTMQuery *tmQuery = nil;
//    NSInvocation *invocation = nil;
//    NSUInteger *row = indexPath.row;
//    NSInteger *journalId = self.journalId;
//    
//    if(self.isSearching){
//        
////        queriesInProgress = self.pendingOperations.searchQueriesInProgress;
//        
//        //get args row and match
//        NSString *match = self.searchBar.text;
//        
//        // create a singature from the selector
//        SEL selector = @selector(getTitleAndIdForRow:whereJournalEquals:andTitleMatch:);
//        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
//        invocation = [NSInvocation invocationWithMethodSignature:sig];
//        
//        //setup invocation and args
//        [invocation setTarget:self.sql];
//        [invocation setSelector:selector];
//        [invocation setArgument:&row atIndex:2];
//        [invocation setArgument:&journalId atIndex:3];
//        [invocation setArgument:&match atIndex:4];
//        [invocation retainArguments];
//        
//    }else{
//        
////        queriesInProgress = self.pendingOperations.queriesInProgress;
//        
//        // create a singature from the selector
//        SEL selector = @selector(getTitleAndIdForRow:whereJournalEquals:);
//        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
//        invocation = [NSInvocation invocationWithMethodSignature:sig];
//        
//        //setup invocation
//        [invocation setTarget:self.sql];
//        [invocation setSelector:selector];
//        [invocation setArgument:&row atIndex:2];
//        [invocation setArgument:&journalId atIndex:3];
//        [invocation retainArguments];
//        
//    }
//    
////    if (![queriesInProgress.allKeys containsObject:indexPath]) {
////        NSLog(@"not in pending operations %@", indexPath);
////        
////        tmQuery = [[NLSTMQuery alloc] initWithInvocation:invocation andDelegate:self];
////        
////        [queriesInProgress setObject:tmQuery forKey:indexPath];
////        [self.pendingOperations.queryQueue addOperation:tmQuery];
////    }
//    
//}


@end
