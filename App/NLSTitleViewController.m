//
//  NLSTitleViewController.m
//  App
//
//  Created by Amir on 7/23/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSTitleViewController.h"
#import "NLSDetailViewController.h"

@interface NLSTitleViewController ()

@end

@implementation NLSTitleViewController

@synthesize sql = _sql;
@synthesize searchBar = _searchBar;
@synthesize searchBarController = _searchBarController;
@synthesize isSearching = _isSearching;
@synthesize tableView = _tableView;
@synthesize window = _window;
@synthesize greenSub = _greenSub;
@synthesize titles = _titles;
@synthesize pendingOperations = _pendingOperations;


UIImageView *navBarHairlineImageView;

- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}


#pragma mark - view lifecycle

- (void)loadView
{
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:YES forType:1];
    self.sql = [NLSSQLAPI sharedManager];
    
    //setup titles cache
    self.titles = [[GKCache alloc] init];
    [self.titles setName:@"titlesCache"];
    [self.titles setDelegate:self];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView reloadData];
    
    self.tableView = tableView;
    self.view = tableView;
    self.isSearching = NO;
    
    self.greenSub = [[UIView alloc] initWithFrame:CGRectMake(0, -44, 320, 86)];
    self.greenSub.backgroundColor = [UIColor colorWithHexString:searchGreen];
    
    self.title = @"Titles";
}

- (void)viewDidLoad
{
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:NO forType:1];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self loadSearchBar];
    [self setNeedsStatusBarAppearanceUpdate];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"view will appear");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
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

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)row WhereTitleMatch:str
{
    return [self.sql getTitleAndIdForRow:row whereTitleMatch:str];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)row
{
    return [self.sql getTitleAndIdForRow:(NSInteger)row];
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
    

    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        // 1: To provide feedback to the user, create a UIActivityIndicatorView and set it as the cellís accessory view.
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }
    
    
    // 2: The data source contains instances of TitleModels. Get a hold of each of them based on the indexPath of the row.
    NLSTitleModel *tm = [[NLSTitleModel alloc] initWithCellId:indexPath.row];
    
    if(![self.titles objectForKey:indexPath]){
        //add to cache and begin operations
        NSLog(@"Not found in cache. querying persistent store");
        [self.titles setObject:tm forKey:indexPath];
        
    }else{
        tm = [self.titles objectForKey:indexPath];
        NSLog(@"yay!!, found in cache: %@", tm.title);
    }

//    if (tableView == self.searchDisplayController.searchResultsTableView){
//        tm = [self getTitleAndIdForRow:(NSUInteger)indexPath.row WhereTitleMatch:self.searchBar.text];
//    }else{
//        tm = [self getTitleAndIdForRow:(NSUInteger)indexPath.row];
//    }
  
    
    // 3: Inspect the TitleModel. If its data is downloaded, display the data, and stop the activity indicator.
    if (tm.hasData) {
        NSLog(@"tm hasData: %@ rowId: %ld", tm.data, tm.rowId);
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.textLabel.text = tm.title;
        
    }
    // 4: If downloading the title has failed, display a placeholder to display the failure, and stop the activity indicator.
    else if (tm.isFailed) {
        NSLog(@"tm is failed");
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.textLabel.text = @"Failed to load";
        
    }
    // 5: Otherwise, the title has not been downloaded yet. Start the download and filtering operations (theyíre not yet implemented), and display a placeholder that indicates you are working on it. Start the activity indicator to show user something is going on.
    else {
        NSLog(@"tm will load");
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.textLabel.text = @"Loading...";
        [self startOperationsForTitleModel:tm atIndexPath:indexPath];

    }
    
    return cell;
}

#pragma mark - ImageDownloader delegate


- (void)sqlQueryDidFinish:(SQLQuery *)query {
    
    // 1: Check for the indexPath of the operation, whether it is a download, or filtration.
    NSIndexPath *indexPath = query.indexPathInTableView;
    NSLog(@"sqlQueryDidFinish. will update cell at: %@", indexPath);
    
    // 2: Get hold of the TitleModel instance.
    NLSTitleModel *tm = query.titleModel;
    
    // 3: Replace the updated TitleModel in the main data source (Titles array).
    [self.titles removeObjectForKey:indexPath];
    [self.titles setObject:tm forKey:indexPath];
    
    // 4: Update UI.
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];

    
    // 5: Remove the operation from downloadsInProgress (or filtrationsInProgress).
    [self.pendingOperations.queriesInProgress removeObjectForKey:indexPath];
}


#pragma mark TM Operations

// 1: To keep it simple, you pass in an instance of TitleModel that requires operations, along with its indexPath.
- (void)startOperationsForTitleModel:(NLSTitleModel *)tm atIndexPath:(NSIndexPath *)indexPath
{
 
    NSLog(@"operating on cell: %@", indexPath);
    // 2: You inspect it to see whether it has data if so, then ignore it.
    if (!tm.hasData) {
        NSLog(@"tm has data %d", tm.hasData);
        // 3: If it does not have an title, start query by calling startQueryForTitleModel:atIndexPath:
        [self startQueryForTitleModel:tm atIndexPath:indexPath];
    }
    
}

- (void)startQueryForTitleModel:(NLSTitleModel *)tm atIndexPath:(NSIndexPath *)indexPath {
    
    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
    if (![self.pendingOperations.queriesInProgress.allKeys containsObject:indexPath]) {
        NSLog(@"not in pending operations %@", indexPath);

        // 2: If not, create an instance of SQLQuery by using the designated initializer, and set TitleViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of TitleModel, and then add it to the download queue.
        SQLQuery *sqlQuery = [[SQLQuery alloc] initWithTitleModel:tm atIndexPath:indexPath delegate:self];
        [self.pendingOperations.queriesInProgress setObject:sqlQuery forKey:indexPath];
        [self.pendingOperations.queryQueue addOperation:sqlQuery];
    }
}

- (void)startAttributingTextForTitleModel:(NLSTitleModel *)tm atIndexPath:(NSIndexPath *)indexPath {
    
    // 3: If not, create an instance of ImageDownloader by using the designated initializer, and set ListViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of PhotoRecord, and then add it to the download queue. You also add it to downloadsInProgress to help keep track of things.
//    if (![self.pendingOperations.filtrationsInProgress.allKeys containsObject:indexPath]) {
//        
//        // 4: If not, start one by using the designated initializer.
//        // Start filtration
//        ImageFiltration *imageFiltration = [[ImageFiltration alloc] initWithPhotoRecord:record atIndexPath:indexPath delegate:self];
//        
//        // 5: This one is a little tricky. You first must check to see if this particular indexPath has a pending download; if so, you make this filtering operation dependent on that. Otherwise, you donít need dependency.
//        ImageDownloader *dependency = [self.pendingOperations.downloadsInProgress objectForKey:indexPath];
//        if (dependency)
//            [imageFiltration addDependency:dependency];
//        
//        [self.pendingOperations.filtrationsInProgress setObject:imageFiltration forKey:indexPath];
//        [self.pendingOperations.filtrationQueue addOperation:imageFiltration];
//    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NLSTableViewCell *cell = (NLSTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString *string = [[NSString alloc] init];
    string = cell.textLabel.text;
    NSInteger rowId = cell.rowId;
    NSLog(@"id: %lu, title: %@", (unsigned long)rowId, string);
    
    //Push new view
    NLSDetailViewController *dvc = [[NLSDetailViewController alloc] init];
    dvc.abstractId = rowId;
    [self.navigationController pushViewController:dvc animated:TRUE];
}


#pragma mark Search Controller

- (void)hideNavShadow {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationBarBackground"]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    [navigationBar setShadowImage:[UIImage new]];
    navBarHairlineImageView = [self findHairlineImageViewUnder:navigationBar];

}

- (void)loadSearchBar {
    
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
    searchBarController.searchBar.translucent = YES;
    searchBarController.searchBar.backgroundImage = [[UIImage alloc] init];
    searchBarController.searchBar.backgroundColor =  [UIColor colorWithHexString:searchGreen];
    searchBarController.searchBar.barTintColor = [UIColor colorWithHexString:searchGreen];
    searchBarController.searchBar.tintColor = [UIColor colorWithHexString:searchGreen];

    
    self.searchBarController = searchBarController;
    self.searchBar = self.searchBarController.searchBar;
    
    
    self.tableView.tableHeaderView = self.searchBarController.searchBar;
    [self.view insertSubview:self.greenSub belowSubview:self.searchBar];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"Text change isSearching: %d for: %@",self.isSearching, searchString);
    
    for (UIView *subview in self.view.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")])
        {
            [self.greenSub removeFromSuperview];
            [subview insertSubview:self.greenSub atIndex:1];
        }
    }    
    
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
    [self.greenSub removeFromSuperview];
    [self.view insertSubview:self.greenSub belowSubview:self.searchBar];
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.isSearching = NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"Did hide view clicked");
}

#pragma mark Utils

- (UIImageView *) findHairlineImageViewUnder:(UIView *)view
{
     NSLog(@"Find hairline image %@", view);
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
         NSLog(@"found hairline image %@", view);
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

#pragma mark -
#pragma mark - UIScrollView delegate


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 1: As soon as the user starts scrolling, you will want to suspend all operations and take a look at what the user wants to see.
    [self suspendAllOperations];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 2: If the value of decelerate is NO, that means the user stopped dragging the table view. Therefore you want to resume suspended operations, cancel operations for offscreen cells, and start operations for onscreen cells.
    if (!decelerate) {
        [self loadTitlesForOnscreenCells];
        [self resumeAllOperations];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 3: This delegate method tells you that table view stopped scrolling, so you will do the same as in #2.
    [self loadTitlesForOnscreenCells];
    [self resumeAllOperations];
}

#pragma mark -
#pragma mark - Cancelling, suspending, resuming queues / operations


- (void)suspendAllOperations {
    [self.pendingOperations.queryQueue setSuspended:YES];
}


- (void)resumeAllOperations {
    [self.pendingOperations.queryQueue setSuspended:NO];
}


- (void)cancelAllOperations {
    [self.pendingOperations.queryQueue cancelAllOperations];
}


- (void)loadTitlesForOnscreenCells {
    
    // 1: Get a set of visible rows.
    NSSet *visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    
    // 2: Get a set of all pending operations (download and filtration).
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.queriesInProgress allKeys]];

    
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // 3: Rows (or indexPaths) that need an operation = visible rows n pendings.
    [toBeStarted minusSet:pendingOperations];
    
    // 4: Rows (or indexPaths) that their operations should be cancelled = pendings ñ visible rows.
    [toBeCancelled minusSet:visibleRows];
    
    // 5: Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        
        SQLQuery *pendingQuery = [self.pendingOperations.queriesInProgress objectForKey:anIndexPath];
        [pendingQuery cancel];
        [self.pendingOperations.queriesInProgress removeObjectForKey:anIndexPath];
        
    }
    toBeCancelled = nil;
    
    // 6: Loop through those to be started, and call startOperationsForPhotoRecord:atIndexPath: for each.
    for (NSIndexPath *anIndexPath in toBeStarted) {
        
        NLSTitleModel *tmToProcess = [self.titles objectForKey:anIndexPath];
        [self startOperationsForTitleModel:tmToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
    
}




@end
