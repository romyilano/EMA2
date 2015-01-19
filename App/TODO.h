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