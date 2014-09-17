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

UIImageView *navBarHairlineImageView;

#pragma mark - view lifecycle

- (void)loadView
{
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:YES forType:1];
    self.sql = [NLSSQLAPI sharedManager];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    self.tableView = tableView;
    self.view = tableView;
    self.isSearching = NO;
    
    self.title = @"Titles";
}

- (void)viewDidLoad
{
    
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:NO forType:1];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self loadSearchBar];
//    [self hideNavShadow];
    [self setNeedsStatusBarAppearanceUpdate];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    navBarHairlineImageView.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    navBarHairlineImageView.hidden = YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
        return [self getTitleCountWhereTitleMatch];
    }else{
        return [self getTitleCount];
    }

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // The header for the section is the region name -- get this from the region at the section index.
    return @"All Titles";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *MyIdentifier = @"Cell";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
    }    

    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView){
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
                 value:[UIColor colorWithHexString:@"#777777"]
                 range:NSMakeRange(0, [year length])];
    
    //Descriptor strings
    NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithAttributedString:year];
    NSMutableAttributedString *meshDescriptors = [[NSMutableAttributedString alloc] initWithString:[tm.descriptors componentsJoinedByString:@", "]];
    

    [meshDescriptors addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"AvenirNext-Medium" size:10]
                            range:NSMakeRange(0, [meshDescriptors length])];
    
    [detailText appendAttributedString:meshDescriptors];
    
    cell.detailTextLabel.attributedText = detailText;
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:emaGreen];
    
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

-(void)hideNavShadow
{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground"]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
    navBarHairlineImageView = [self findHairlineImageViewUnder:navigationBar];

}

-(void)loadSearchBar {
    
    NSLog(@"Loading SearchBar");
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"Avenir" size:14]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor blueColor]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor blueColor]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor whiteColor],NSForegroundColorAttributeName,
                             [UIFont fontWithName:@"Avenir" size:16], NSFontAttributeName,
                             nil] forState:UIControlStateNormal];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];

    searchBar.barStyle = UISearchBarStyleDefault;
    searchBar.placeholder = @"Title, MeSH and Year Search";
    searchBar.delegate = self;
    searchBar.translucent = YES;
    searchBar.backgroundImage = [[UIImage alloc] init];
    searchBar.backgroundColor =  [UIColor colorWithHexString:searchGreen];
    searchBar.barTintColor = [UIColor colorWithHexString:searchGreen];
    searchBar.tintColor = [UIColor colorWithHexString:searchGreen];
    
    UISearchDisplayController *searchBarController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchBarController.delegate = self;
    searchBarController.searchResultsDataSource = self;
    searchBarController.searchResultsDelegate = self;
    
    self.searchBarController = searchBarController;
    self.searchBar = self.searchBarController.searchBar;
    self.tableView.tableHeaderView = self.searchBarController.searchBar;
    
}

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
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    NSLog(@"starting search");
    self.isSearching = YES;
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.isSearching = NO;
}

#pragma mark Utils

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

- (UIImage*) imageWithColor:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



@end
