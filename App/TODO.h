/*
 
 TODOs:

 Advanced Search
 Colors
 Abstract Header
 Header Art
 Art for ICONS / Splash
 test on multi-device
 IGA, UTI, ED: caps in Titles
 last row of table partially hidden
 JAMA, QJM in Journals
 WebView open in Safari option
 springer links http://link.springer.com/journal/10654/12/6/page/1
 Add scholar links http://scholar.google.com  Sci Justice. 2001 Jul-Sep;41(3):197-9
 bug when tapping near cancel on active search bar

 */

//    BOOL success;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *databasePath = [self.GetDocumentDirectory stringByAppendingPathComponent:@"ema.sqlite"];
//    success = [fileManager fileExistsAtPath:databasePath];
//    if(success) {
//        NSLog(@"DB exists in writeable Docs dir");
//    }
//    else{
//        NSLog(@"DB does not exist in writeable Docs dir, copying...");
//        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ema.sqlite"];
//        [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
//    }

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    NSLog(@"Text change isSearching: %d for: %@",self.isSearching, searchString);
//
//    if([searchString length] > 1){
//
//        //temporarily disable controller
//        controller.delegate = nil;
//        [self.searchTitles removeAllObjects];
//        [self.searchDisplayController.searchResultsTableView reloadData];
//        //re-enable controller
//        controller.delegate = self;
//
//        NSLog(@"shouldReloadTableForSearchString");
//        return YES;
//
//    }else{
//
//        return NO;
//    }
//
//}
//
//
//- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
//{
//    NSLog(@"Starting search");
//    controller.  searchResultsTableView.tableHeaderView.tintColor = [UIColor redColor];
//}
//
//- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
//    self.isSearching = YES;
//    NSLog(@"didShowSearchResultsTableView");
//
//}
//
//-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
//{
//    NSLog(@"Cancel clicked or did end search");
//    self.isSearching = NO;
//    self.searchReset = YES;
//    self.prevSearchRowCount = [self.searchDisplayController.searchResultsTableView numberOfRowsInSection:0];
//    [self.searchTitles removeAllObjects];
//    [self.tableView reloadData];
//}

//-(void)createTitles
//{
//    NSLog(@"Creating FTS titles table");
//
//    NSString *sql = @"DROP TABLE IF EXISTS titles;"
//                    @"CREATE VIRTUAL TABLE IF NOT EXISTS titles USING fts4(a NUMBER, t TEXT);"
//                    @"INSERT INTO titles
//                    SELECT e.abstract_id, e.title || ' ' || group_concat(name, ' ') || ' ' || e.author || ' ' || e.country || ' ' || e.journal_year
//                    FROM erpubtbl e
//                    JOIN abstract_mesh a ON e.id = a.abstract_id
//                    JOIN mesh_descriptor m ON a.mesh_id = m.id
//                    GROUP BY a.abstract_id;
//
//    [self executeInQueueWithSQL:sql withLabel:@"Titles"];
//
//}


DROP TABLE IF EXISTS titles;
CREATE VIRTUAL TABLE IF NOT EXISTS titles USING fts4(a NUMBER, t TEXT, tokenize=porter);
INSERT INTO titles
SELECT a.id, a.abstract || ' ' || group_concat(md.name, ' ')
FROM abstracts a
JOIN abstract_mesh am ON a.pmid = am.pmid
JOIN mesh_descriptor md ON am.mesh_id = md.id
GROUP BY a.id;

delete from erpubtbl where id not in (select a from titles);
drop table abstracts;
VACUUM;
CREATE INDEX mesh_descriptor_name_idx on mesh_descriptor (name);
CREATE INDEX journals_journal_title_idx on journals (journal_title);
CREATE INDEX erpubtbl_year_idx on erpubtbl (journal_year);
INSERT INTO titles(titles) VALUES('optimize');

//
//-(void)createDescriptors
//{
//    NSLog(@"Creating FTS descriptors table");
//
//    NSString *sql =     @"DROP TABLE IF EXISTS descriptors;"
//                        @"CREATE VIRTUAL TABLE IF NOT EXISTS descriptors USING fts4(mesh_id NUMBER, descriptor TEXT);"
//                        @"INSERT INTO descriptors SELECT id, name FROM mesh_descriptor;";
//
//    [self executeInQueueWithSQL:sql withLabel:@"Descriptors"];
//
//}

//caching protocol?

//#pragma mark Cache Operations
//
//- (void)startQueryForIndexPath:(NSIndexPath *)indexPath
//{
//    NSMutableDictionary *queriesInProgress = nil;
//    NLSTMQuery *tmQuery = nil;
//    NSInvocation *invocation = nil;
//    NSUInteger *row = indexPath.row;
//    
//    if(self.isSearching){
//        
//        queriesInProgress = self.pendingOperations.searchQueriesInProgress;
//        
//        //get args row and match
//        NSString *match = self.searchBar.text;
//        
//        // create a singature from the selector
//        SEL selector = @selector(getTitleAndIdForRowOkapi:whereTitleMatch:);
//        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
//        invocation = [NSInvocation invocationWithMethodSignature:sig];
//        
//        //setup invocation and args
//        [invocation setTarget:self.sql];
//        [invocation setSelector:selector];
//        [invocation setArgument:&row atIndex:2];
//        [invocation setArgument:&match atIndex:3];
//        [invocation retainArguments];
//        
//    }else{
//        
//        queriesInProgress = self.pendingOperations.queriesInProgress;
//        
//        // create a signature from the selector
//        // check to see what fields are missing from tm
//        // if title, get title, if mesh get mesh
//        
//        //getMeshDescriptorsForId:tm.rowId
//        //SEL selector = @selector(getTitleAndIdForRow:);
//        SEL selector = @selector(getEmptyTitleModelWithDescriptorsForId:);
//        
//        NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
//        invocation = [NSInvocation invocationWithMethodSignature:sig];
//        
//        //setup invocation
//        [invocation setTarget:self.sql];
//        [invocation setSelector:selector];
//        [invocation setArgument:&row atIndex:2];
//        [invocation retainArguments];
//        
//    }
//    
//    if (![queriesInProgress.allKeys containsObject:indexPath]) {
//        NSLog(@"not in pending operations %@", indexPath);
//        
//        tmQuery = [[NLSTMQuery alloc] initWithInvocation:invocation atIndexPath:indexPath andDelegate:self];
//        
//        [queriesInProgress setObject:tmQuery forKey:indexPath];
//        [self.pendingOperations.queryQueue addOperation:tmQuery];
//    }
//    
//    
//}
//
//- (void)queryDidFinish:(NLSQuery*)query
//{
//    //NSLog(@"%@, %ld", NSStringFromSelector(_cmd), (long)query.result);
//    
//    if(self.isSearching){
//        [self.cachePointer removeAllObjects];
//        self.resultsCount = query.result;
//        [self.searchResultsController.tableView reloadData];
//    }else{
//        self.titleCount = query.result;
//        [self.tableView reloadData];
//    }
//    
//}
//
//- (void)sqlQueryDidFinish:(NLSTMQuery *)query
//{
//    
//    // get indexPath
//    NSIndexPath *indexPath = query.indexPathInTableView;
//    NSLog(@"sqlQueryDidFinish. will update cell at: %@", indexPath);
//    
//    // Get the TitleModel instance.
//    NLSTitleModel *tm = query.titleModel;
//    
//    // Replace the updated TitleModel in the main data source.
//    if([self.cachePointer count] > indexPath.row){
//        NSLog(@"cachePointer has values, replacing %@ at index %ld", tm, (unsigned long)indexPath.row);
//        [[self.cachePointer objectAtIndex:indexPath.row] addMeshArrayFromTm:tm];
//    }
//    
//    // Update UI.
//    if(self.isSearching){
//        NSLog(@"self.isSearching is searching...");
//        [self.searchResultsController.tableView reloadData];
//        [self.pendingOperations.searchQueriesInProgress removeObjectForKey:indexPath];
//    }else{
//        NSLog(@"self.isSearching not searching");
//        [self.tableView beginUpdates];
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView endUpdates];
//        [self.pendingOperations.queriesInProgress removeObjectForKey:indexPath];
//    }
//    
//    
//}
//
//- (void)loadTitlesForOnscreenCells
//{
//    
//    // Get a set of visible rows.
//    NSSet *visibleRows = nil;
//    NSMutableDictionary *queriesInProgress = nil;
//    
//    if(self.isSearching){
//        NSLog(@"is searching...");
//        visibleRows = [NSSet setWithArray:[self.searchResultsController.tableView indexPathsForVisibleRows]];
//        queriesInProgress = self.pendingOperations.searchQueriesInProgress;
//    }else{
//        visibleRows = [NSSet setWithArray:[self.tableView indexPathsForVisibleRows]];
//        queriesInProgress = self.pendingOperations.queriesInProgress;
//    }
//    
//    // Get a set of all pending operations
//    NSMutableSet *pendingOperations = [NSMutableSet setWithArray:[queriesInProgress allKeys]];
//    NSMutableSet *toBeCancelled = [pendingOperations mutableCopy];
//    NSMutableSet *toBeStarted = [visibleRows mutableCopy];
//    
//    // Rows (or indexPaths) that need an operation = visible rows n pendings.
//    [toBeStarted minusSet:pendingOperations];
//    
//    // Rows (or indexPaths) that their operations should be cancelled = pendings visible rows.
//    [toBeCancelled minusSet:visibleRows];
//    
//    // Loop through those to be cancelled, cancel them, and remove their reference from PendingOperations.
//    for (NSIndexPath *anIndexPath in toBeCancelled) {
//        NLSTMQuery *pendingQuery = [queriesInProgress objectForKey:anIndexPath];
//        [pendingQuery cancel];
//        [queriesInProgress removeObjectForKey:anIndexPath];
//        
//    }
//    toBeCancelled = nil;
//    
//    // Loop through those to be started, and call startOperationsForTitleModel:atIndexPath: for each.
//    for (NSIndexPath *anIndexPath in toBeStarted) {
//        NLSTitleModel *tmToProcess = [self.cachePointer objectAtIndex:anIndexPath.row];
//        [self startOperationsForTitleModel:tmToProcess atIndexPath:anIndexPath];
//    }
//    toBeStarted = nil;
//    
//}
//
//
//#pragma mark - Cancelling, suspending, resuming queues / operations
//
//- (void)suspendAllOperations
//{
//    [self.pendingOperations.queryQueue setSuspended:YES];
//}
//
//- (void)resumeAllOperations
//{
//    [self.pendingOperations.queryQueue setSuspended:NO];
//}
//
//- (void)cancelAllOperations
//{
//    [self.pendingOperations.queryQueue cancelAllOperations];
//}

//-(NSInteger)getTitleCount
//{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//
//    // create a signature from the selector
//    SEL selector = @selector(getTitleCount);
//    NSMethodSignature *sig = [[self.sql class]instanceMethodSignatureForSelector:selector];
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
//
//    // setup invocation
//    [invocation setTarget:self.sql];
//    [invocation setSelector:selector];
//
//    //create query and add to queue
//    NLSQuery *nlsQuery = [[NLSQuery alloc] initWithInvocation:invocation andDelegate:self];
//    [self.pendingOperations.queryQueue addOperation:nlsQuery];
//
//}
//
//-(NSInteger)getTitleCountWhereTitleMatch
//{
//    NSLog(@"%@", NSStringFromSelector(_cmd));
//
//    //get ref to prop
//    NSString *match = self.searchBar.text;
//
//    // create a singature from the selector
//    SEL selector = @selector(getTitleCountWhereTitleMatch:);
//    NSMethodSignature *sig = [[self.sql class] instanceMethodSignatureForSelector:selector];
//    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
//
//    //setup invocation
//    [invocation setTarget:self.sql];
//    [invocation setSelector:selector];
//    [invocation setArgument:&match atIndex:2];
//    [invocation retainArguments];
//
//    //create query and add to queue
//    NLSQuery *nlsQuery = [[NLSQuery alloc] initWithInvocation:invocation andDelegate:self];
//    [self.pendingOperations.queryQueue addOperation:nlsQuery];
//
//}

//- (void)queryDidFinish:(NSInteger *)result
//{
//    NSLog(@"titleCount %@, %ld", NSStringFromSelector(_cmd), (long)result);
//    self.titleCount = [[NSNumber alloc] initWithLong:result];
//    [self.tableView reloadData];
//
//}