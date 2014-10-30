//
//  NLSTitleViewController.m
//  App
//
//  Created by Amir on 7/23/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSTitleViewController.h"
#import "NLSDetailViewController.h"

@interface NLSTitleViewController ()

@end

@implementation NLSTitleViewController

@synthesize sql = _sql;
@synthesize searchBar = _searchBar;
@synthesize searchController = _searchController;
@synthesize searchResultsController = _searchResultsController;
@synthesize isSearching = _isSearching;
@synthesize tableView = _tableView;
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

    //Setup SQL for counts
    self.sql = [NLSSQLAPI sharedManager];
    
    //caches
    self.titles = [[NSMutableArray alloc] init];
    self.searchTitles = [[NSMutableArray alloc] init];
    
    //Setup last index
    self.lastIndex = [[NSIndexPath alloc] init];

    //Set title
    self.title = @"Titles";
}

- (void)viewDidLoad
{
    NSLog(@"View Did Load");
    //Setup table view
    UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    self.tableView = tableView;
    self.view = self.tableView;
    self.isSearching = NO;
    self.searchReset = NO;
    self.prevSearchRowCount = 0;
    
    //load searchbar
    [self loadSearchBar];
    
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
                                value:[UIFont fontWithName:@"Helvetica Neue" size:10]
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
                      value:[UIFont fontWithName:@"Helvetica Neue" size:12]
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


#pragma mark Cache Operations


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
//        tv = self.searchDisplayController.searchResultsTableView;
        tv = self.searchResultsController.tableView;
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
//        visibleRows = [NSSet setWithArray:[self.searchDisplayController.searchResultsTableView indexPathsForVisibleRows]];
        visibleRows = [NSSet setWithArray:[self.searchResultsController.tableView indexPathsForVisibleRows]];
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


#pragma mark Search Controller Delegates

- (void)loadSearchBar
{
    
    NSLog(@"Loading SearchBar");
    
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
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
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;

}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchString = [self.searchController.searchBar text];
    NSLog(@"updateSearchResultsForSearchController: %@", searchString);
    [self.tableView reloadData];
    
    if([searchString length] > 1){
        [self.searchTitles removeAllObjects];
        [self.searchResultsController.tableView reloadData];
        self.title = searchString;
        NSLog(@"shouldReloadTableForSearchString");
        
    }

}


- (void)presentSearchController:(UISearchController *)searchController
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"y: %f", self.searchController.searchBar.frame.origin.y);
    self.isSearching = YES;
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"y: %f", self.searchController.searchBar.frame.origin.y);

}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.isSearching = NO;
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.isSearching = NO;
    [self.tableView reloadData];
    self.title = @"Titles";
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
