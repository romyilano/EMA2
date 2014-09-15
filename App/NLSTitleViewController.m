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
#import "EDColor.h"
#import "PBJActivityIndicator.h"

@interface NLSTitleViewController ()

@end

@implementation NLSTitleViewController

@synthesize sql = _sql;
@synthesize searchBar = _searchBar;
@synthesize searchBarController = _searchBarController;
@synthesize isSearching = _isSearching;
@synthesize tableView = _tableView;


#pragma mark - view lifecycle

- (void)loadView
{
    self.sql = [NLSSQLAPI sharedManager];
    
    NSLog(@"UIViewController loadTitleView");

    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    self.tableView = tableView;
    self.view = tableView;
    self.isSearching = NO;

    [self loadSearchBar];
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:YES forType:1];
    
    self.title = @"Titles";

}

-(void)loadSearchBar {
    
    NSLog(@"Loading SearchBar");
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    self.searchBar.placeholder = @"Title, MeSH and Key Search";

    self.searchBar.delegate = self;
    self.searchBar.translucent = YES;
    
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchBar.backgroundColor =  [UIColor colorWithHexString:@"#407993"];
    self.searchBar.barTintColor = [UIColor colorWithHexString:@"#407993"];
    self.searchBar.tintColor = [UIColor colorWithHexString:@"#407993"];
    
    
    
    self.searchBarController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBarController.delegate = self;
    self.searchBarController.searchResultsDataSource = self;
    self.searchBarController.searchResultsDelegate = self;

    self.tableView.tableHeaderView = self.searchBar;
}


- (void)viewDidLoad
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:NO forType:1];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SQL Overides

-(NSInteger)getTitleCount
{
    return (NSInteger)[self.sql getTitleCount];
}

-(NSInteger)getTitleCountWhereTitleMatch
{
    return (NSInteger)[self.sql getTitleCountWhereTitleMatch:self.searchBar.text];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)row WhereTitleMatch:str
{
    return [self.sql getTitleAndIdForRow:row whereTitleMatch:str];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)row
{
    return [self.sql getTitleAndIdForRow:(NSUInteger)row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"tableView is searching count for: %@", self.searchBar.text);
        return [self getTitleCountWhereTitleMatch];
    }else{
        return [self getTitleCount];
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return @"All Titles";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"Cell";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
    }
    
//    NSLog(@"indexPath: %ld", (long)indexPath.row);

    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView){
        NSLog(@"tableView is searching: %@", self.searchBar.text);
        tm = [self getTitleAndIdForRow:(NSUInteger)indexPath.row WhereTitleMatch:self.searchBar.text];
    }else{
        tm = [self getTitleAndIdForRow:(NSUInteger)indexPath.row];
        
    }
    
    //Attribute string for year
    NSMutableAttributedString *year;
    NSString *journalAndYear  = [NSString stringWithFormat:@"%@, %@ \n", tm.journal_abv, tm.year ];
    year = [[NSMutableAttributedString alloc] initWithString:journalAndYear];
    
    [year addAttribute:NSKernAttributeName
                 value:[NSNumber numberWithFloat:0.5]
                 range:NSMakeRange(0, [year length])];
    
    [year addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:@"AvenirNext-Medium" size:12]
                 range:NSMakeRange(0, [year length])];

    [year addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithHexString:@"#777"]
                 range:NSMakeRange(0, [year length])];
    
    //Descriptor strings
    NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithAttributedString:year];
    NSMutableAttributedString *meshDescriptors = [[NSMutableAttributedString alloc] initWithString:[tm.descriptors componentsJoinedByString:@", "]];
    
//    for(id mesh in tm.descriptors){
//        NSLog(@"%@", mesh);
//        //            [meshDescriptors addAttribute:NSLinkAttributeName
//        //                     value:@"descriptor://"
//        //                     range:NSMakeRange(0, [meshDescriptors length])];
//        
//
//    }
    [meshDescriptors addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"AvenirNext-Medium" size:10]
                            range:NSMakeRange(0, [meshDescriptors length])];
    
    [detailText appendAttributedString:meshDescriptors];
    
    cell.detailTextLabel.attributedText = detailText;
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#15829e"];
    
    //Attribute string for label
    NSMutableAttributedString *title;
    
    title = [[NSMutableAttributedString alloc] initWithString:tm.title];
    
    [title addAttribute:NSKernAttributeName
                  value:[NSNumber numberWithFloat:0.5]
                  range:NSMakeRange(0, [tm.title length])];
    
    [title addAttribute:NSFontAttributeName
                  value:[UIFont fontWithName:@"AvenirNext-Medium" size:12]
                  range:NSMakeRange(0, [tm.title length])];
    
    cell.textLabel.attributedText = title;

    
    //Set row id property of cell
    cell.rowId = tm.rowId;
    
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

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"Text change isSearching: %d for: %@",self.isSearching, searchString);
    
    
    if([searchString length] != 0) {
        self.isSearching = YES;
    } else {
        self.isSearching = NO;
    }

    if([searchString length] > 1){

        /*
        //temporarily disable controller
        controller.delegate = nil;

        //update the boolean search text
        NSMutableString *string = self.searchBar.text.mutableCopy;
        for(NSString *key in replacements){
            [string replaceOccurrencesOfString:key withString:replacements[key] options:0 range:NSMakeRange(0, string.length)];
        }
        self.searchBar.text = string.copy;

        //re-enable controller
        controller.delegate = self;
        */
        NSLog(@"shouldReloadTableForSearchString");
        return YES;
        
    }else{
        return NO;
    }

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
//    [self searchTableList];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.isSearching = YES;
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.isSearching = NO;
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
