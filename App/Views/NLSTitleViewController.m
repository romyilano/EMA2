//
//  NLSTitleViewController.m
//  App
//
//  Created by Amir Djavaherian on 7/23/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSTitleViewController.h"
#import "NLSDetailViewController.h"

@interface NLSTitleViewController ()

@end

@implementation NLSTitleViewController

@synthesize sql = _sql;
@synthesize defactoTitle = _defactoTitle;
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
@synthesize resultsCount = _resultsCount;
@synthesize titleCount = _titleCount;
@synthesize lastIndex = _lastIndex;
@synthesize translucentView = _translucentView;
@synthesize settings = _settings;

//Setup titles cache
- (NLSPendingOperations *)pendingOperations
{
    if (!_pendingOperations) {
        _pendingOperations = [[NLSPendingOperations alloc] init];
    }
    return _pendingOperations;
}

- (NSMutableArray*)cachePointer
{
    if (self.isSearching){
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
    self.defactoTitle = titlesString;
    self.navigationItem.title = self.defactoTitle;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.resultsCount = 0;
    self.titleCount = 0;
    
    //load searchbar
    [self loadSearchBar];
    
    //Clear back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowWelcomeOnLaunch"]){

        [self loadTranslucentView];
        self.tableView.tableHeaderView.layer.zPosition++;
        
    }
    
    //Options button
    UIImage *optionsImage = [UIImage imageNamed:@"Options-50"];
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc]
                                  initWithImage:optionsImage style:UIBarButtonItemStylePlain target:self action:@selector(presentSettingsController)];
    self.navigationItem.rightBarButtonItem = newButton;
    
    //get title count
    [self getTitleCount];
    
}

-(void)presentSettingsController
{
    NSLog(@"present settings controller");

    
    
    
    NLSSettingsViewController *settingsController = [[NLSSettingsViewController alloc] init];
    
    settingsController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    settingsController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    self.settings = settingsController;
    
    [self.navigationController presentViewController:settingsController animated:YES completion:nil];
    
}

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
    self.tableView.tableHeaderView.layer.zPosition++;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    //add color to search field
    UIView *subviews = [self.searchBar.subviews lastObject];
    UITextField *textView = (id)[subviews.subviews objectAtIndex:1];
    
    textView.backgroundColor = [UIColor colorWithHexString:textFieldBlue];
    
}

- (void)loadTranslucentView
{
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.navigationController.view.bounds];
    
    UIVisualEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.navigationController.view.bounds];
    
    [blurEffectView.contentView addSubview:vibrancyEffectView];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UITextView *messageText = [[UITextView alloc] initWithFrame:CGRectMake(0,110,bounds.size.width,bounds.size.height)];

    messageText.layer.shadowColor = [[UIColor blackColor] CGColor];
    messageText.layer.shadowOffset = CGSizeMake(1.0,1.0);
    messageText.layer.shadowRadius = 3.0;
    [messageText setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:16]];
    [messageText setBackgroundColor:[UIColor clearColor]];
    [messageText setTextColor:[UIColor whiteColor]];
    [messageText setTextAlignment:NSTextAlignmentCenter];
    [messageText setEditable:NO];
    
    messageText.text =  @"EMA is a powerful, searchable Readers' Advisory From CCME.org\n\n"
                        @"Searchable terms include: subject headings, keywords in titles or abstracts, numerical years, journal names or abbreviations.  The @ or * symbols are wildcards.\n\n"
                        @"All searches are full-text and boolean. \"Ands\" are implicit.\n\n"
                        @"For example: baseball not injur@ 2005 or softball injury.\n\n"
                        @"Example 2: 2006 tick@ mite@ spider@ not allergy\n\n"
                        @"Tap or swipe the screen to start.";

    // Label for vibrant text
    UILabel *searchLabel = [[UILabel alloc] init];
    [searchLabel setText:@"Welcome"];
    [searchLabel setFont:[UIFont systemFontOfSize:70.0f]];
    [searchLabel sizeToFit];
    [searchLabel setCenter: self.view.center];
    CGRect searchRect = searchLabel.frame;
    searchRect.origin.y = 30;
    searchLabel.frame = searchRect;
    
    [vibrancyEffectView.contentView addSubview:messageText];
    [vibrancyEffectView.contentView addSubview:searchLabel];
    
    self.translucentView = blurEffectView;
    
    UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fadeTranslucentView)];
    UISwipeGestureRecognizer *swipeH = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fadeTranslucentView)];
    UISwipeGestureRecognizer *swipeV = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fadeTranslucentView)];
    [swipeH setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
    [swipeV setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown )];

    
    [self.translucentView addGestureRecognizer:dismiss];
    [self.translucentView addGestureRecognizer:swipeH];
    [self.translucentView addGestureRecognizer:swipeV];
    
    [self.navigationController.view addSubview:self.translucentView];

    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.translucentView setAlpha:1.0];
    } completion:nil];
    
    
}

- (void)fadeTranslucentView
{
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.translucentView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         if([self.translucentView isDescendantOfView:self.view]){
                             [self.translucentView removeFromSuperview];
                             [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SettingsShowWelcomeOnLaunch"];
                         }
                     }];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super viewWillAppear:animated];
    
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIEdgeInsets insets = UIEdgeInsetsZero;

    CGFloat height = self.tableView.bounds.size.height;
    frame.size.height += height;


    insets.top = height;
    insets.bottom = height;

    
    self.tableView.frame = frame;
    self.tableView.scrollIndicatorInsets = insets;
//    self.tableView.contentInset = insets;
    
    
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
    NSLog(@"%@", NSStringFromSelector(_cmd));

    // create a singature from the selector
    SEL selector = @selector(getTitleCount);
    NSMethodSignature *sig = [[self.sql class]instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    
    NLSQuery *nlsQuery = [[NLSQuery alloc] initWithInvocation:invocation andDelegate:self];    
    [self.pendingOperations.queryQueue addOperation:nlsQuery];
    
}

-(NSInteger)getTitleCountWhereTitleMatch
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

    //get ref to prop
    NSString *match = self.searchBar.text;
    
    // create a singature from the selector
    SEL selector = @selector(getTitleCountWhereTitleMatch:);
    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    //setup invocation
    [invocation setTarget:self.sql];
    [invocation setSelector:selector];
    [invocation setArgument:&match atIndex:2];
    [invocation retainArguments];
    
    //create query and add to queue
    NLSQuery *nlsQuery = [[NLSQuery alloc] initWithInvocation:invocation andDelegate:self];
    [self.pendingOperations.queryQueue addOperation:nlsQuery];
    
}

#pragma mark - Table view data source
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(self.view.frame.origin.x + 4, self.view.frame.origin.y + 4, self.view.frame.size.width, 20);
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:[self tableView:tableView titleForHeaderInSection:section] attributes:nil];
    [attString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"HelveticaNeue" size:14]
                      range:NSMakeRange(0, [attString length])];
    [attString addAttribute:NSForegroundColorAttributeName
                      value:[UIColor grayColor]
                      range:NSMakeRange(0, [attString length])];
    myLabel.attributedText = attString;
    
    UIToolbar *headerView = [[UIToolbar alloc] init];
    headerView.translucent = YES;
    headerView.tintColor = [UIColor colorWithHexString:searchGreen];
    [headerView addSubview:myLabel];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if(self.isSearching){
        return self.resultsCount;
    }else{
        return self.titleCount;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // The header for the section is the region name -- get this from the region at the section index.

    if (self.isSearching){
        NSString *header = [[NSString alloc] initWithFormat:@"%@ : %@", resultsString, @(self.resultsCount).stringValue];
        return header;
    }else{
        NSString *header = [[NSString alloc] initWithFormat:@"%@ : %@", titlesString, @(self.titleCount).stringValue];
        return header;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Table View: %@", tableView);
    NSString *identifier = @"CellIdentifier";
    NLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[NLSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        cell.accessoryView = activityIndicatorView;
    }

    cell.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "];

    
    // Get tm from cache
    NLSTitleModel *tm = nil;
    
    if([self.cachePointer count] > indexPath.row){
        tm = [self.cachePointer objectAtIndex:indexPath.row];
    }else{
        tm = [[NLSTitleModel alloc] initWithCellId:indexPath.row andSearchBarText:nil];
        NSLog(@"Adding %@ to cache.", tm);
        [self.cachePointer addObject:tm];
    }
    
    // Check for data
    if (tm.hasData) {
        
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        
        //Attribute string for year
        NSString *journalAndYear  = [NSString stringWithFormat:@"%@, %@ \n", tm.journal_abv, tm.year ];
        NSMutableAttributedString *journalLine = [[NSMutableAttributedString alloc] initWithString:journalAndYear];
        
        [journalLine addAttribute:NSKernAttributeName
                     value:[NSNumber numberWithFloat:0.5]
                     range:NSMakeRange(0, [journalLine length])];
        
        [journalLine addAttribute:NSFontAttributeName
                     value:[UIFont fontWithName:@"Helvetica Neue" size:12]
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
        if([meshDescriptors length] >= 1){
            NSRange endComma;
            endComma.location = ([meshDescriptors length] - 2);
            endComma.length = 1;
            [meshDescriptors deleteCharactersInRange:endComma];
            

            
        }
        
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
        
    } else if (tm.isFailed) {
        
        NSLog(@"tm is failed");
        [((UIActivityIndicatorView *)cell.accessoryView) stopAnimating];
        cell.textLabel.text = @"Failed to load";
        
    } else {
        
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
        [self startQueryForIndexPath:indexPath];
    }
    
}

- (void)startQueryForIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *queriesInProgress = nil;
    NLSTMQuery *tmQuery = nil;
    NSInvocation *invocation = nil;
    NSUInteger *row = indexPath.row;
    
    if(self.isSearching){
        
        queriesInProgress = self.pendingOperations.searchQueriesInProgress;
        
        //get args row and match
        NSString *match = self.searchBar.text;
        
        // create a singature from the selector
        SEL selector = @selector(getTitleAndIdForRowOkapi:whereTitleMatch:);
        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:sig];
        
        //setup invocation and args
        [invocation setTarget:self.sql];
        [invocation setSelector:selector];
        [invocation setArgument:&row atIndex:2];
        [invocation setArgument:&match atIndex:3];
        [invocation retainArguments];
    
    }else{
        
        queriesInProgress = self.pendingOperations.queriesInProgress;
        
        // create a singature from the selector
        SEL selector = @selector(getTitleAndIdForRow:);
        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
        invocation = [NSInvocation invocationWithMethodSignature:sig];
        
        //setup invocation
        [invocation setTarget:self.sql];
        [invocation setSelector:selector];
        [invocation setArgument:&row atIndex:2];
        [invocation retainArguments];
    
    }
    
    if (![queriesInProgress.allKeys containsObject:indexPath]) {
        NSLog(@"not in pending operations %@", indexPath);
        
        tmQuery = [[NLSTMQuery alloc] initWithInvocation:invocation atIndexPath:indexPath andDelegate:self];
        
        [queriesInProgress setObject:tmQuery forKey:indexPath];
        [self.pendingOperations.queryQueue addOperation:tmQuery];
    }
    
    
}

- (void)queryDidFinish:(NLSQuery*)query
{
    NSLog(@"%@, %ld", NSStringFromSelector(_cmd), (long)query.result);

    if(self.isSearching){
        [self.cachePointer removeAllObjects];
        self.resultsCount = query.result;
        [self.searchResultsController.tableView reloadData];
    }else{
        self.titleCount = query.result;
        [self.tableView reloadData];
    }

}

- (void)sqlQueryDidFinish:(NLSTMQuery *)query
{
    
    // get indexPath
    NSIndexPath *indexPath = query.indexPathInTableView;
    NSLog(@"sqlQueryDidFinish. will update cell at: %@", indexPath);
    
    // Get the TitleModel instance.
    NLSTitleModel *tm = query.titleModel;
    
    // Replace the updated TitleModel in the main data source.
    if([self.cachePointer count] > indexPath.row){
        NSLog(@"cachePointer has values, replacing %@ at index %ld", tm, (unsigned long)indexPath.row);
        [self.cachePointer replaceObjectAtIndex:indexPath.row withObject:tm];
    }

    // Update UI.
    if(self.isSearching){
        NSLog(@"self.isSearching is searching...");
        [self.searchResultsController.tableView reloadData];
        [self.pendingOperations.searchQueriesInProgress removeObjectForKey:indexPath];
    }else{
        NSLog(@"self.isSearching not searching");
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self.pendingOperations.queriesInProgress removeObjectForKey:indexPath];
    }

    
}

- (void)loadTitlesForOnscreenCells {
    
    // Get a set of visible rows.
    NSSet *visibleRows = nil;
    NSMutableDictionary *queriesInProgress = nil;
    
    if(self.isSearching){
        NSLog(@"is searching...");
        visibleRows = [NSSet setWithArray:[self.searchResultsController.tableView indexPathsForVisibleRows]];
        queriesInProgress = self.pendingOperations.searchQueriesInProgress;
    }else{
        visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
        queriesInProgress = self.pendingOperations.queriesInProgress;
    }
    
    // Get a set of all pending operations
    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[queriesInProgress allKeys]];
    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
    
    // Rows (or indexPaths) that need an operation = visible rows n pendings.
    [toBeStarted minusSet:pendingOperations];
    
    // Rows (or indexPaths) that their operations should be cancelled = pendings visible rows.
    [toBeCancelled minusSet:visibleRows];
    
    // Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
    for (NSIndexPath *anIndexPath in toBeCancelled) {
        NLSTMQuery *pendingQuery = [queriesInProgress objectForKey:anIndexPath];
        [pendingQuery cancel];
        [queriesInProgress removeObjectForKey:anIndexPath];
        
    }
    toBeCancelled = nil;
    
    // Loop through those to be started, and call startOperationsForTitleModel:atIndexPath: for each.
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


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchString = [self.searchController.searchBar text];
    NSLog(@"updateSearchResultsForSearchController, searchString: %@", searchString);

    if(self.isSearching){
        if([searchString length] > 1){
            [self cancelAllOperations];
            [self getTitleCountWhereTitleMatch];
            self.navigationItem.title = searchString;
            NSLog(@"shouldReloadTableForSearchString");
        }else{
            self.navigationItem.title = searchingString;
        }
    }

}

- (void)presentSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
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
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.isSearching = NO;
    self.navigationItem.title = self.defactoTitle;
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
