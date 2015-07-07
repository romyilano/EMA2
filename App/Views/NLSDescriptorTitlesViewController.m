//
//  NLSDescriptorTitlesViewController.m
//  App
//
//  Created by Amir Djavaherian on 8/7/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSDescriptorTitlesViewController.h"

@interface NLSDescriptorTitlesViewController ()

@end

@implementation NLSDescriptorTitlesViewController

@synthesize section = _section;
@synthesize letters = _letters;
@synthesize meshId = _meshId;
@synthesize descriptor = _descriptor;

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seenSearchTut"];
    self.title = self.descriptor;
    self.defactoTitle = self.descriptor;
    [self primeTitleCache];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - SQL Overides

-(NSInteger)getTitleCount
{
    NSLog(@"getTitleCount");
    
    //get ref to prop
    NSInteger *meshId = self.meshId;
    
    // create a signature from the selector
    SEL selector = @selector(getTitleCountWhereMeshEquals:);
    NSMethodSignature *sig = [[self.sql class]instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&meshId atIndex:2];
    [invocation retainArguments];
    
    //create query and add to queue
    NLSQuery *nlsQuery = [[NLSQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:nlsQuery];
    
}

-(void)primeTitleCache
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // get ref to prop
    NSInteger *meshId = self.meshId;
    
    // temp result set
    NSMutableArray *tempResultSet;
    
    // create a signature from the selector
    SEL selector = @selector(getTitleModelsWhereMeshEquals:);
    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    // setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&meshId atIndex:2];
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
    NSInteger *meshId = self.meshId;
    
    // create a signature from the selector
    SEL selector = @selector(getTitleAndIdForRow:whereMeshEquals:andTitleMatch:);
    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
    invocation = [NSInvocation invocationWithMethodSignature:sig];

    //setup invocation and args
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&row atIndex:2];
    [invocation setArgument:&meshId atIndex:3];
    [invocation setArgument:&match atIndex:4];
    [invocation retainArguments];
    
    //create query and add to queue
    NLSTMArrayQuery *nlsTMArrayQuery = [[NLSTMArrayQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:nlsTMArrayQuery];
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TitleCellIdentifier"];
    NSInteger rowAtIndex = indexPath.row;
    
    if (self.isSearching){
        
        if ([self.cachePointer count] >> 0){
            NSLog(@"indexPath.row %ld >> cachePointer.count: %ld", indexPath.row, [self.cachePointer count] );
            rowAtIndex = [[self.cachePointer objectAtIndex:indexPath.row] integerValue];
        } else {
            rowAtIndex = 1;
        }
        
        if (!cell) {
            NSLog(@"no cell, is searching pulling row %ld", rowAtIndex);
            cell = [[NLSTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifierDefault:@"TitleCellIdentifier"];
            
        } else {
            NSLog(@"re-using cell at indexPath %ld, pulling %ld", indexPath.row, rowAtIndex);
            if ([self.cachePointer count] >= 1){
                NSLog(@"have stuff in search cache %ld", rowAtIndex);
                [cell updateCellWithId:rowAtIndex];
            }
            
        }
        
    } else {
        
        if (!cell) {
            NSLog(@"no cell, no search");
            cell = [[NLSTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifierDefault:@"TitleCellIdentifier"];
        } else {
            rowAtIndex = [[self.cachePointer objectAtIndex:indexPath.row] integerValue];
            NSLog(@"no search re-using cell at indexPath %ld, pulling %ld", indexPath.row, rowAtIndex);
            [cell updateCellWithId:rowAtIndex];
        }
    }
    
    return cell;
}



-(NSInteger)getTitleCountWhereTitleMatch
{
    NSLog(@"getTitleCountWhereTitleContains");
    
    //get ref to prop
    NSInteger *meshId = self.meshId;
    NSString *match = self.searchBar.text;
    
    // create a singature from the selector
    SEL selector = @selector(getTitleCountWhereMeshEquals:andTitleMatch:);
    NSMethodSignature *sig = [[self.sql class]instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&meshId atIndex:2];
    [invocation setArgument:&match atIndex:3];
    [invocation retainArguments];
    
    //create query and add to queue
    NLSQuery *nlsQuery = [[NLSQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:nlsQuery];
    
}


@end
