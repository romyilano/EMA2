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
@synthesize searchTitles = _searchTitles;
@synthesize cachePointer = _cachePointer;
@synthesize pendingOperations = _pendingOperations;
@synthesize searchReset = _searchReset;
@synthesize prevSearchRowCount = _prevSearchRowCount;
@synthesize lastIndex = _lastIndex;

//Setup titles cache
- (PendingOperations *)pendingOperations
{
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (NSMutableArray*)cachePointer
{
    if (self.isSearching){
        NSLog(@"Using searchTitles cache");
        return self.searchTitles;
    }else{
        return self.titles;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - view lifecycle

- (void)loadView
{
    //Setup indicator
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:YES forType:1];

    //Setup SQL for counts
    self.sql = [NLSSQLAPI sharedManager];
    
    //caches
    self.titles = [[NSMutableArray alloc] init];
    self.searchTitles = [[NSMutableArray alloc] init];
    
    //Setup last index
    self.lastIndex = [[NSIndexPath alloc] init];
    
    //Setup table view
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    //[tableView reloadData];
    
    self.tableView = tableView;
    self.view = tableView;
    self.isSearching = NO;
    self.searchReset = NO;
    self.prevSearchRowCount = 0;
    self.greenSub = [[UIView alloc] initWithFrame:CGRectMake(0, -44, 320, 86)];
    self.greenSub.backgroundColor = [UIColor colorWithHexString:searchGreen];
    
    self.title = @"Titles";
}

- (void)viewDidLoad
{
    NSLog(@"View Did Load");
    [[PBJActivityIndicator sharedActivityIndicator] setActivity:NO forType:1];
    [self loadSearchBar];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //Clear back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Dispose of any resources that can be recreated.
    [self.titles removeAllObjects];
    [self.searchTitles removeAllObjects];
    [self.tableView reloadData];
    [self.searchBarController.searchResultsTableView reloadData];
    [super didReceiveMemoryWarning];
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

-(NLSTitleModel*)createTitleForRow:(NSInteger)row
{

    __block NSInteger bRow = row;
    __block NSString *bString = self.searchBar.text;
    
    if (self.isSearching){
        NSLog(@"Using searchTitles cache with str: %@", bString);
        
        NLSTitleModel *tm = [[NLSTitleModel alloc] initWithCellId:bRow andSearchBarText:bString];
        tm.sqlQuery = ^{
            return [self.sql getTitleAndIdForRow:bRow whereTitleMatch:bString];
        };
        return tm;
    }else{
        NLSTitleModel *tm  = [[NLSTitleModel alloc] initWithCellId:bRow andSearchBarText:nil];
        tm.sqlQuery = ^{
            return [self.sql getTitleAndIdForRow:bRow];
        };
        
        return tm;
    }
    
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
    if (self.isSearching){
        
        if(self.searchReset){
            self.searchReset = NO;
            NSLog(@"Search reset prev row count: %ld", (long)self.prevSearchRowCount);
            return self.prevSearchRowCount;
        }
        
        NSLog(@"Title Count From Match: %ld", (long)[self getTitleCountWhereTitleMatch]);
        return [self getTitleCountWhereTitleMatch];
    }else{
        NSLog(@"Title Count %ld", (long)[self getTitleCount]);
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

    //NSLog(@"Table View: %@", tableView);
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        // 1: To provide feedback to the user, create a UIActivityIndicatorView and set it as the cellís accessory view.
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }else{
        cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
        cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
    }
    
    // 2: The data source contains instances of TitleModels. Get a hold of each of them based on the indexPath of the row.

    // Get tm from cache
    NLSTitleModel *tm = nil;
    
    if([self.cachePointer count] > indexPath.row){
        tm = [self.cachePointer objectAtIndex:indexPath.row];
    }else{
        tm = [self createTitleForRow:indexPath.row];
        NSLog(@"Adding %@ to cache.", tm);
        [self.cachePointer addObject:tm];
        //[self addRowToCachesViaPath:indexPath];
    }
    
    // 3: Inspect the TitleModel. If its data is downloaded, display the data, and stop the activity indicator.
    if (tm.hasData) {
        
        NSLog(@"tm hasData: %@ rowId: %ld", tm.data, (long)tm.rowId);
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        
        //Attribute string for year

        NSString *journalAndYear  = [NSString stringWithFormat:@"%@, %@ \n", tm.journal_abv, tm.year ];
        NSMutableAttributedString *journalLine = [[NSMutableAttributedString alloc] initWithString:journalAndYear];
        
        [journalLine addAttribute:NSKernAttributeName
                     value:[NSNumber numberWithFloat:0.5]
                     range:NSMakeRange(0, [journalLine length])];
        
        [journalLine addAttribute:NSFontAttributeName
                     value:[UIFont fontWithName:@"AvenirNext-Medium" size:12]
                     range:NSMakeRange(0, [journalLine length])];
        
        [journalLine addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithHexString:@"#777777"]
                     range:NSMakeRange(0, [journalLine length])];
        
        //Descriptor strings
        NSMutableAttributedString *meshDescriptors = [[NSMutableAttributedString alloc] initWithString:@""];
        for(NSDictionary *dict in tm.descriptors){
            NSString *str = [[NSString alloc] initWithFormat:@"%@, ", [dict valueForKey:@"name"]];
            NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:str];
            [meshDescriptors appendAttributedString:aStr];
        }
        
        //Trim last comma
        NSRange endComma;
        endComma.location = ([meshDescriptors length] - 2);
        endComma.length = 1;
        [meshDescriptors deleteCharactersInRange:endComma];
        
        [meshDescriptors addAttribute:NSFontAttributeName
                                value:[UIFont fontWithName:@"AvenirNext-Medium" size:10]
                                range:NSMakeRange(0, [meshDescriptors length])];
        [meshDescriptors addAttribute:NSForegroundColorAttributeName
                            value:[UIColor colorWithHexString:emaGreen]
                            range:NSMakeRange(0, [meshDescriptors length])];
        
        
        //Create Detail Text and append journal line and descriptors
        NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithAttributedString:journalLine];
        [detailText appendAttributedString:meshDescriptors];
        
        
        //Attribute string for label
        NSMutableAttributedString *title;
        
        title = [[NSMutableAttributedString alloc] initWithString:tm.title];
        
        [title addAttribute:NSKernAttributeName
                      value:[NSNumber numberWithFloat:0.5]
                      range:NSMakeRange(0, [tm.title length])];
        
        [title addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"AvenirNext-Medium" size:12]
                      range:NSMakeRange(0, [tm.title length])];

        cell.detailTextLabel.attributedText = detailText;
        cell.textLabel.attributedText = title;
        
        //Set row id property of cell
        cell.rowId = tm.rowId;
        
    }
    // 4: If downloading the title has failed, display a placeholder to display the failure, and stop the activity indicator.
    else if (tm.isFailed) {
        NSLog(@"tm is failed");
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.textLabel.text = @"Failed to load";
        
    }
    // 5: Otherwise, the title has not been downloaded yet. Start the query, and display a placeholder that indicates you are working on it. Start the activity indicator to show user something is going on.
    else {
        [((UIActivityIndicatorView *)cell.accessoryView) startAnimating];
        cell.textLabel.text = @"Loading...";
        [self startOperationsForTitleModel:tm atIndexPath:indexPath];

    }
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    self.lastIndex = [self.tableView indexPathsForVisibleRows].lastObject;
//    NSLog(@"LAST index, %@", self.lastIndex);
//    if(indexPath == self.lastIndex){
//        
//        NSLog(@"Whoohoo, last index %@", indexPath);
//        
//        NSInteger lookAhead = 15;
//        if((self.lastIndex.row + lookAhead) > [self getTitleCount]){
//            lookAhead = 0;
//        }
//        
//        for(int i = 0; i <= lookAhead; i++){
//            NSIndexPath *newPath = [NSIndexPath indexPathForRow:(indexPath.row + i) inSection:indexPath.section];
//            [self addPathToCaches:newPath];
//        }
//    }
//    
//}

#pragma mark Cache Operations

//- (void)addRowToCachesViaPath:(NSIndexPath*)path
//{
//    NLSTitleModel *tm = [self createTitleForRow:path.row];
//    NSLog(@"Adding %@ to cache.", tm);
//    [self.cachePointer addObject:tm];
//    [self startOperationsForTitleModel:tm atIndexPath:path];
//    
//}

- (void)startOperationsForTitleModel:(NLSTitleModel *)tm atIndexPath:(NSIndexPath *)indexPath
{
 
    // 2: You inspect it to see whether it has data if so, then ignore it.
    if (!tm.hasData) {
        NSLog(@"tm at: %@ does not have data %d", indexPath, tm.hasData);
        // 3: If it does not have an title, start query by calling startQueryForTitleModel:atIndexPath:
        [self startQueryForTitleModel:tm atIndexPath:indexPath];
    }
    
}

- (void)startQueryForTitleModel:(NLSTitleModel *)tm atIndexPath:(NSIndexPath *)indexPath
{
    
    // 1: First, check for the particular indexPath to see if there is already an operation in downloadsInProgress for it. If so, ignore it.
    if (![self.pendingOperations.queriesInProgress.allKeys containsObject:indexPath]) {
        NSLog(@"not in pending operations %@", indexPath);

        // 2: If not, create an instance of SQLQuery by using the designated initializer, and set TitleViewController as the delegate. Pass in the appropriate indexPath and a pointer to the instance of TitleModel, and then add it to the download queue.
        SQLQuery *sqlQuery = [[SQLQuery alloc] initWithTitleModel:tm atIndexPath:indexPath delegate:self];
        [self.pendingOperations.queriesInProgress setObject:sqlQuery forKey:indexPath];
        [self.pendingOperations.queryQueue addOperation:sqlQuery];

    }
}

- (void)sqlQueryDidFinish:(SQLQuery *)query
{
    
    // 1: Check for the indexPath of the operation, whether it is a download, or filtration.
    NSIndexPath *indexPath = query.indexPathInTableView;
    NSLog(@"sqlQueryDidFinish. will update cell at: %@", indexPath);
    
    // 2: Get hold of the TitleModel instance.
    NLSTitleModel *tm = query.titleModel;
    
    // 3: Replace the updated TitleModel in the main data source (Titles array).
    if([self.cachePointer count] > indexPath.row){
        NSLog(@"cachePointer has values, replacing %@ at index %ld", tm, (unsigned long)indexPath.row);
        [self.cachePointer replaceObjectAtIndex:indexPath.row withObject:tm];
    }

    // 4: Update UI.
    UITableView *tv = nil;
    if(!self.isSearching){
        NSLog(@"self.isSearching not searching");
        tv = self.tableView;
        [tv beginUpdates];
        [tv reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tv endUpdates];
    }else{
        NSLog(@"self.isSearching is searching...");
        tv = self.searchDisplayController.searchResultsTableView;
        [tv reloadData];
    }
    
    // 5: Remove the operation from downloadsInProgress (or filtrationsInProgress).
    [self.pendingOperations.queriesInProgress removeObjectForKey:indexPath];
    
}

- (void)loadTitlesForOnscreenCells {
    
    // 1: Get a set of visible rows.
    NSSet *visibleRows = nil;
    
    if(self.isSearching){
        NSLog(@"is searching...");
        visibleRows = [NSSet setWithArray:[self.searchDisplayController.searchResultsTableView indexPathsForVisibleRows]];
    }else{
        visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
    }
    
    // 2: Get a set of all pending operations
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[self.pendingOperations.queriesInProgress allKeys]];
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // 3: Rows (or indexPaths) that need an operation = visible rows n pendings.
    [toBeStarted minusSet:pendingOperations];
    
    // 4: Rows (or indexPaths) that their operations should be cancelled = pendings visible rows.
    [toBeCancelled minusSet:visibleRows];
    
    // 5: Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        SQLQuery *pendingQuery = [self.pendingOperations.queriesInProgress objectForKey:anIndexPath];
        [pendingQuery cancel];
        [self.pendingOperations.queriesInProgress removeObjectForKey:anIndexPath];
        
    }
    toBeCancelled = nil;
    
    // 6: Loop through those to be started, and call startOperationsForTitleModel:atIndexPath: for each.
    for (NSIndexPath *anIndexPath in toBeStarted) {
        NLSTitleModel *tmToProcess = [self.cachePointer objectAtIndex:anIndexPath.row];
        [self startOperationsForTitleModel:tmToProcess atIndexPath:anIndexPath];
    }
    toBeStarted = nil;
    
}


#pragma mark - Cancelling, suspending, resuming queues / operations

- (void)suspendAllOperations
{
    [self.pendingOperations.queryQueue setSuspended:YES];
}

- (void)resumeAllOperations
{
    [self.pendingOperations.queryQueue setSuspended:NO];
}

- (void)cancelAllOperations
{
    [self.pendingOperations.queryQueue cancelAllOperations];
}

#pragma mark DidSelectRow

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

- (void)loadSearchBar
{
    
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
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.tableView.tableHeaderView = self.searchBarController.searchBar;
    [self.view insertSubview:self.greenSub belowSubview:self.searchBar];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"Text change isSearching: %d for: %@",self.isSearching, searchString);
    for (UIView *subview in self.view.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")])
        {
            [self.greenSub removeFromSuperview];
            [subview insertSubview:self.greenSub atIndex:1];
        }
    }

    if([searchString length] > 1){
        
        //temporarily disable controller
        controller.delegate = nil;
        [self.searchTitles removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
        //re-enable controller
        controller.delegate = self;

        NSLog(@"shouldReloadTableForSearchString");
        return YES;
        
    }else{
 
        return NO;
    }

}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"Starting search");
    [self.greenSub removeFromSuperview];
    [self.view insertSubview:self.greenSub belowSubview:self.searchBar];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    self.isSearching = YES;
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"Cancel clicked or did end search");
    self.isSearching = NO;
    self.searchReset = YES;
    self.prevSearchRowCount = [self.searchDisplayController.searchResultsTableView numberOfRowsInSection:0];
    [self.searchTitles removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 1: As soon as the user starts scrolling, you will want to suspend all operations and take a look at what the user wants to see.
    [self suspendAllOperations];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 2: If the value of decelerate is NO, that means the user stopped dragging the table view. Therefore you want to resume suspended operations, cancel operations for offscreen cells, and start operations for onscreen cells.
    if (!decelerate) {
        [self loadTitlesForOnscreenCells];
        [self resumeAllOperations];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 3: This delegate method tells you that table view stopped scrolling, so you will do the same as in #2.
    [self loadTitlesForOnscreenCells];
    [self resumeAllOperations];
}



@end
