//
//  NLSTitleViewController.m
//  App
//
//  Created by Amir on 7/23/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSTitleViewController.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"
#import "NLSDetailViewController.h"

@interface NLSTitleViewController ()

@end

@implementation NLSTitleViewController

@synthesize sql = _sql;
@synthesize searchBar = _searchBar;
@synthesize searchBarController = _searchBarController;
@synthesize isSearching = _isSearching;


#pragma mark - view lifecycle

- (void)loadView
{
    NLSSQLAPI *sqlapi = [NLSSQLAPI sharedManager];
    self.sql = sqlapi;
    
    NSLog(@"UIViewController loadTitleView");
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    self.tableView = tableView;
    self.view = tableView;
    
    [self loadSearchBar];
}

-(void)loadSearchBar {
    
    NSLog(@"Loading SearchBar");
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.searchBar.placeholder = @"Keyword Search";
    self.searchBar.translucent = YES;
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchBarController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBarController.delegate = self;
    self.searchBarController.searchResultsDataSource = self;
    self.searchBarController.searchResultsDelegate = self;    

    self.title = @"Titles";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"numberOfSectionsInTableView, %d", 1);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"tableView is self.searchDisplayController.searchResultsTableView");
        return [self.sql getTitleCountWhereTitleContains:self.searchBar.text];
    }else{
        return [self.sql getTitleCount];
    }
    

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.

    return @"All Titles";
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"MyReuseIdentifier";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    
    NSLog(@"indexPath: %ld", (long)indexPath.row);

    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"tableView is self.searchDisplayController.searchResultsTableView in cellForRowAtIndexPath: %ld", (long)indexPath.row);
        tm = [self.sql getTitleAndIdForRow:(NSUInteger)indexPath.row whereTitleMatch:self.searchBar.text];
    }else{
        tm = [self.sql getTitleAndIdForRow:(NSUInteger)indexPath.row];
    }
    
    
    
    cell.textLabel.text = tm.title;
    cell.rowId = tm.rowId;
    
    NSLog(@"cell.rowId: %lu, textLabel: %@", (unsigned long)cell.rowId, cell.textLabel.text);
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NLSTableViewCell *cell = (NLSTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString *string = [[NSString alloc] init];
    string = cell.textLabel.text;
    NSUInteger rowId = cell.rowId;
    NSLog(@"id: %lu, title: %@", (unsigned long)rowId, string);
    
    //Push new view
    NLSDetailViewController *dvc = [[NLSDetailViewController alloc] init];
    dvc.abstractId = rowId;
    [self.navigationController pushViewController:dvc animated:TRUE];
}


#pragma mark Search Controller

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Text change - %d",self.isSearching);
    
    //Remove all objects first.
//    [filteredContentList removeAllObjects];
    
    if([searchText length] != 0) {
        self.isSearching = YES;
//        [self searchTableList];
    }
    else {
        self.isSearching = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
//    [self searchTableList];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
