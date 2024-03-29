//
//  NLSDescriptorViewController.m
//  App
//
//  Created by Amir Djavaherian on 8/6/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSDescriptorViewController.h"

@interface NLSDescriptorViewController ()

@end

@implementation NLSDescriptorViewController

@synthesize sql = _sql;
@synthesize letters = _letters;
@synthesize tableView = _tableView;
@synthesize defactoTitle = _defactoTitle;
@synthesize isSearching = _isSearching;
@synthesize searchBar = _searchBar;
@synthesize searchController = _searchController;
@synthesize searchResultsController = _searchResultsController;

- (void)loadView
{
    [super loadView];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
 
    NSLog(@"init NLSDescriptorViewController");
    self.sql = [NLSSQLAPI sharedManager];
    self.letters = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
    self.searchTitles = [[NSMutableArray alloc] init];
    
    self.defactoTitle = descriptorsString;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NLSTableView *tableView = [[NLSTableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.sectionIndexColor = [UIColor colorWithHexString:linkBlue];
    
    self.tableView = tableView;
    self.view = tableView;
    
    self.navigationItem.title = self.defactoTitle;
    
    [self loadSearchBar];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"numberOfSectionsInTableView, %ld", (unsigned long)[self.letters count]);
    
    if(self.isSearching){
        return 1;
    }else{
        return (NSInteger)[self.letters count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if (self.isSearching){
        
        if(self.searchReset){
            self.searchReset = NO;
            NSLog(@"Search reset prev row count: %ld", (long)self.prevSearchRowCount);
            return self.prevSearchRowCount;
        }        
        NSInteger count = (long)[self.sql getCountFromDescriptorsWhereSectionLike:self.searchBar.text];
        return count;
    }else{

        NSInteger count = (long)[self.sql getCountFromDescriptorsWhereSectionLike:[self.letters objectAtIndex:(NSUInteger)section]];
        return count;
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.isSearching && [self.searchBar.text length] > 1){
        return resultsString;
    }else{
        return [self.letters objectAtIndex:(NSUInteger)section];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.letters;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSLog(@"sectionForSectionIndexTitle: %@ atIndex: %ld", title, (long)index);
    return (NSInteger)[self.letters indexOfObject:title];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    cell.textLabel.textColor = [UIColor blackColor];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *myIdentifier = @"MyReuseIdentifier";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier];
    }
    
    NSLog(@"indexPath.row: %ld, indexPath.section: %ld", (long)indexPath.row, (long)indexPath.section);
    
    NLSDescriptorModel *dm = nil;
    if(self.isSearching){
        dm = [self.sql getDescriptorForRow:(NSInteger)indexPath.row whereSectionLike:self.searchBar.text];
    }else{
        dm = [self.sql getDescriptorForRow:(NSInteger)indexPath.row whereSectionLike:[self.letters objectAtIndex:(NSUInteger)indexPath.section]];
    }
    
    cell.name = dm.name;
    cell.rowId = dm.rowId;
    cell.textLabel.text = dm.name;
    
    NSLog(@"cell.rowId: %lu, textLabel: %@", (unsigned long)cell.rowId, cell.textLabel.text);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NLSTableViewCell *cell = (NLSTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSLog(@"cell id: %lu, name: %@", (unsigned long)cell.rowId, cell.name);
    
    NLSDescriptorTitlesViewController *dtvc = [[NLSDescriptorTitlesViewController alloc] init];

    dtvc.letters = self.letters;
    dtvc.meshId = cell.rowId;
    dtvc.descriptor = cell.name;
    
    //Push new view
    [self.navigationController pushViewController:dtvc animated:TRUE];
}

#pragma mark Search Controller Delegates

- (void)loadSearchBar
{
    
    NSLog(@"Loading SearchBar");
    
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    UITableView *myTv = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    searchResultsController.tableView = myTv;
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    searchResultsController.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    searchResultsController.tableView.sectionIndexColor = [UIColor colorWithHexString:linkBlue];
    
    self.searchResultsController = searchResultsController;
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    
    self.searchBar = self.searchController.searchBar;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate = self;
    self.searchBar.translucent = YES;
    
    
    UIView *wrap = [[UIView alloc] initWithFrame:self.searchBar.frame];
    [wrap addSubview:self.searchBar];
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.tableHeaderView.layer.zPosition++;
    
    UIView *subviews = [self.searchBar.subviews lastObject];
    UITextField *textView = (id)[subviews.subviews objectAtIndex:1];

    textView.backgroundColor = [UIColor colorWithHexString:textFieldBlue];
    self.definesPresentationContext = YES;
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchString = [self.searchController.searchBar text];
    NSLog(@"updateSearchResultsForSearchController: %@", searchString);

    [self.searchResultsController.tableView reloadData];
    if([searchString length] <= 1 && self.isSearching){
        self.navigationItem.title = searchingString;
    }else if ([searchString length] > 1){
        [self.searchTitles removeAllObjects];
        [self.searchResultsController.tableView reloadData];
        self.navigationItem.title = searchString;
    }else{
    
    }
    
    NSLog(@"shouldReloadTableForSearchString");
    
    [self.tableView reloadData];
    
}


- (void)presentSearchController:(UISearchController *)searchController
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"y: %f", self.searchController.searchBar.frame.origin.y);
    self.isSearching = YES;
    self.navigationItem.title = searchingString;
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
//    NSLog(@"y: %f", self.searchController.searchBar.frame.origin.y);
    
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.isSearching = NO;
    self.navigationItem.title = self.defactoTitle;
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.isSearching = NO;
    [self.tableView reloadData];
    self.navigationItem.title = self.defactoTitle;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
}


@end
