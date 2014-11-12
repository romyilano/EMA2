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
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"seenSearchTut"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.descriptor;
    self.defactoTitle = self.descriptor;
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
    
    // create a singature from the selector
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


-(NLSTitleModel*)createTitleForRow:(NSInteger)row
{
    
    __block NSInteger bRow = row;
    __block NSString *bString = self.searchBar.text;
    __block NSInteger bMesh = self.meshId;
    
    if (self.isSearching){
        NSLog(@"Using searchTitles cache with str: %@", bString);
        
        NLSTitleModel *tm = [[NLSTitleModel alloc] initWithCellId:bRow andSearchBarText:bString];
        tm.sqlQuery = ^{
            return [self.sql getTitleAndIdForRow:bRow whereMeshEquals:bMesh andTitleMatch:bString];
        };
        return tm;
    }else{
        NLSTitleModel *tm  = [[NLSTitleModel alloc] initWithCellId:bRow andSearchBarText:nil];
        tm.sqlQuery = ^{
            return [self.sql getTitleAndIdForRow:bRow whereMeshEquals:bMesh];
        };
        
        return tm;
    }
    
}


@end
