//
//  NLSSQLAPI.m
//  App
//
//  Created by Amir on 7/23/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSSQLAPI.h"


@interface NLSSQLAPI ()
{
    NSMutableArray *_tableArray;
    NSString *someProperty;
}

@property (nonatomic, retain) NSString *someProperty;

@end

@implementation NLSSQLAPI

@synthesize tableArray = _tableArray;
@synthesize db = _db;
@synthesize queue = _queue;
@synthesize favesDb = _favesDb;
@synthesize someProperty;
@synthesize fileMgr = _fileMgr;
@synthesize homeDir = _homeDir;


#pragma mark Singleton Methods

+(id)sharedManager {
    static NLSSQLAPI *sqlAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlAPI = [[self alloc] init];
    });
    return sqlAPI;
}

-(id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
        [self initDatabase];
    }
    return self;
}

#pragma mark Database Initialization


-(NSString *)GetDocumentDirectory{
    self.fileMgr = [NSFileManager defaultManager];
    self.homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return self.homeDir;
}

- (void) initDatabase
{
    
    NSString *path = [self.GetDocumentDirectory stringByAppendingPathComponent:@"ema.sqlite"];
    FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    self.db = fmdb;
    self.queue = queue;

    NSString *favesPath = [self.GetDocumentDirectory stringByAppendingPathComponent:@"emafaves.sqlite"];
    FMDatabase *favesDb = [FMDatabase databaseWithPath:favesPath];
    self.favesDb = favesDb;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"faves exists: %d",[fileManager fileExistsAtPath:favesPath]);

    
    if(![self.db open]){
        return;
    }else{
        [self performSelectorInBackground:@selector(createTitles) withObject:nil];
        [self performSelectorInBackground:@selector(createDescriptors) withObject:nil];
    }
    
    if (![self.favesDb open]) {
        NSLog(@"faves db not open");
        return;
    }else{
        [self createFavoritesTable];
    }
    
    
}

#pragma mark executeStatements
-(void)executeInQueueWithSQL:(NSString*)sql withLabel:(NSString*)label
{
    [self.queue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeStatements:sql];
        NSLog(@"%@ Success: %d", label, success);
    }];
}


#pragma mark Create

-(void)createTitles
{
    NSLog(@"Creating FTS titles table");
    
    NSString *sql = @"DROP TABLE IF EXISTS titles;"
                    @"CREATE VIRTUAL TABLE IF NOT EXISTS titles USING fts4(a NUMBER, t TEXT);"
                    @"INSERT INTO titles\
                    SELECT e.abstract_id, e.title || ' ' || group_concat(name, ' ') || ' ' || e.author || ' ' || e.country || ' ' || e.journal_year\
                    FROM erpubtbl e\
                    JOIN abstract_mesh a ON e.id = a.abstract_id\
                    JOIN mesh_descriptor m ON a.mesh_id = m.id\
                    GROUP BY a.abstract_id;";

    [self executeInQueueWithSQL:sql withLabel:@"Titles"];

}

-(void)createDescriptors
{
    NSLog(@"Creating FTS descriptors table");
    
    NSString *sql =     @"DROP TABLE IF EXISTS descriptors;"
                        @"CREATE VIRTUAL TABLE IF NOT EXISTS descriptors USING fts4(mesh_id NUMBER, descriptor TEXT);"
                        @"INSERT INTO descriptors SELECT id, name FROM mesh_descriptor;";

    [self executeInQueueWithSQL:sql withLabel:@"Descriptors"];

}

-(void)createFavoritesTable
{
    
    NSLog(@"Creating Favorites table");
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS favorites (id NUMBER, title TEXT);";
    
    BOOL success = [self.favesDb executeStatements:sql];
    NSLog(@"Favorites Success: %d", success);
}

#pragma mark Favorites

-(BOOL)insertIntoFavorites:(NSUInteger)emaId
{
    
    NSString *title = [self getTitleWhereId:emaId];
    NSString *query = [NSString stringWithFormat:@"INSERT INTO favorites (id, title) VALUES (%ld, ?) ", (unsigned long)emaId];
    
    NSLog(@"%@", query);
    FMResultSet *count = [self.favesDb executeQuery:query, title];
    
    if ([count next]) {
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(BOOL)deleteFavorites
{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM favorites"];
    FMResultSet *count = [self.favesDb executeQuery:query];    
    if ([count next]) {
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(BOOL)deleteFromFavorites:(NSUInteger)emaId
{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM favorites WHERE id = %ld;", (unsigned long)emaId];
    FMResultSet *count = [self.favesDb executeQuery:query];
    
    if ([count next]) {
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(BOOL)checkForFavoriteId:(NSUInteger)emaId
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM favorites WHERE id = %ld;", (unsigned long)emaId];
    FMResultSet *count = [self.favesDb executeQuery:query];
    
    if ([count next]) {
        NSLog(@"Total Count in favorites: %d", [count intForColumnIndex:0]);
        if([count intForColumnIndex:0] > 0){
            return 1;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}

-(NLSTitleModel*)getFavoriteForRow:(NSUInteger)val
{
    FMResultSet *rs = [self.favesDb executeQueryWithFormat:@"SELECT id, title FROM favorites LIMIT 1 OFFSET %ld", (long)val];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"id"];
        NSLog(@"result Dict: %@", tm);
    }else{
        NSLog(@"No favorite for row: %ld", (unsigned long)val);
    }
    return tm;
}

-(NSUInteger)getCountFromFavorites
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM favorites"];
    NSLog(@"%@", query);
    
    FMResultSet *count = [self.favesDb executeQuery:query];
    
    if ([count next]) {
        //        NSLog(@"Total Rows in titles: %d where title MATCH %@", [count intForColumnIndex:0], str);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

#pragma mark Titles

-(NSString *)tokenizeSearchString:(NSString*)str
{
    NSDictionary *replacements = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @" AND ", @"\\sand\\s",
                                  @" OR ", @"\\sor\\s",
                                  @" NOT ", @"\\snot\\s",
                                  @"*", @"\\@",
                                  @"", @"\\s[and|AND|or|OR|not|NOT]\\s*$",
                                  @" ", @"\\s+",
                                  @"", @"\\s+$",                                  
                                  nil];
    
    NSMutableString *string = str.mutableCopy;
    for(NSString *key in replacements){
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:key options:NSRegularExpressionCaseInsensitive error:nil];
        NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:replacements[key]];
        string = [modifiedString mutableCopy];
    }
    
    return string.copy;
    
}

-(NSArray*)getTitlesToLimit:(int)limit
{
    //show 10 rows
    FMResultSet *limitTen = [self.db executeQuery:@"SELECT * FROM erpubtbl limit ?", limit];
    
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    
    while ([limitTen next]) {
        //        NSString *title = [limitTen stringForColumn: @"title"];
        //        NSLog(@"Title col in erpubtbl: %@", title);
        [self.tableArray addObject:[limitTen stringForColumn:@"title"]];
    }
    
    NSLog(@"tableArray: %@", titles);
    return titles;
    
}

-(NSString*)getTitleWhereId:(NSUInteger)emaId
{
    NSString *query = [NSString stringWithFormat: @"SELECT title FROM erpubtbl WHERE id = %ld", (long)emaId];
    FMResultSet *title = [self.db executeQuery:query];
    if ([title next]) {
        //        NSString *title = [limitTen stringForColumn: @"title"];
        //        NSLog(@"Title col in erpubtbl: %@", title);
        NSLog(@"stringForTitle: %@", [title stringForColumn:@"title"]);
        return [title stringForColumn:@"title"];
    }else{
        return @"No title";
    }
}

-(NSArray *)getMeshDescriptorsForId:(NSUInteger)emaId
{
    //Get associated mesh descriptors
    NSString *query = [NSString stringWithFormat:@"SELECT a.mesh_id, m.name FROM erpubtbl e JOIN abstract_mesh a ON a.abstract_id = e.id JOIN mesh_descriptor m ON m.id = a.mesh_id WHERE e.id = %ld", (unsigned long)emaId];
    FMResultSet *rs = [self.db executeQuery:query];

    NSMutableArray *mesh_array = [[NSMutableArray alloc] init];

    while ([rs next]) {
        //        NSLog(@"next: %@", [rs2 stringForColumn:@"name"]);
        [mesh_array addObject:[rs stringForColumn:@"name"]];
    }
    
    return [NSArray arrayWithArray:(NSArray*)mesh_array];
}

-(NLSTitleModel*)getTitleForId:(NSUInteger)emaId
{
    NSString * query = [NSString stringWithFormat:@"SELECT e.id, e.title, e.journal_year, j.journal_abv FROM erpubtbl e join journals j ON e.journal_id = j.id WHERE e.id = %ld LIMIT 1", (long)emaId];
    FMResultSet *rs = [self.db executeQuery:query];
    
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.year = [rs stringForColumn:@"journal_year"];
        tm.journal_abv = [rs stringForColumn:@"journal_abv"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"id"];
    }
    
    tm.descriptors = [self getMeshDescriptorsForId:tm.rowId];
    return tm;
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val
{
    NSString * query = [NSString stringWithFormat:@"SELECT e.id, e.title, e.journal_year, j.journal_abv FROM erpubtbl e join journals j ON e.journal_id = j.id LIMIT 1 OFFSET %ld;", (long)val];
    FMResultSet *rs = [self.db executeQuery:query];
    
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.year = [rs stringForColumn:@"journal_year"];
        tm.journal_abv = [rs stringForColumn:@"journal_abv"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"id"];
    }
    
    tm.descriptors = [self getMeshDescriptorsForId:tm.rowId];
    return tm;
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereTitleMatch:(NSString *)str
{
    
    NSString *query = [NSString stringWithFormat:@"SELECT a FROM titles WHERE t MATCH '%@' ORDER BY t LIMIT 1 OFFSET %ld", [self tokenizeSearchString:str], (unsigned long)val];
    NSLog(@"%@", query);
    FMResultSet *rs = [self.db executeQuery:query];
    
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm = [self getTitleForId:(NSUInteger)[rs intForColumn:@"a"]];
    }
    return tm;
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereMeshEquals:(NSUInteger)meshId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT e.abstract_id, e.title, e.journal_year, j.journal_abv\
                       FROM erpubtbl e\
                       JOIN abstract_mesh am\
                       ON am.abstract_id = e.abstract_id\
                       JOIN mesh_descriptor md\
                       ON md.id = am.mesh_id\
                       JOIN journals j\
                       ON e.journal_id = j.id\
                       WHERE md.id = %ld\
                       ORDER BY e.title\
                       LIMIT 1\
                       OFFSET %ld", (unsigned long)meshId, (unsigned long)val];
    
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"abstract_id"];
        tm.year = [rs stringForColumn:@"journal_year"];
        tm.journal_abv = [rs stringForColumn:@"journal_abv"];
        NSLog(@"result Dict: %@", tm);
    }
    
    tm.descriptors = [self getMeshDescriptorsForId:tm.rowId];
    
    return tm;
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereMeshEquals:(NSUInteger)meshId andTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT t.a\
                       FROM erpubtbl e\
                       JOIN abstract_mesh am\
                       ON am.abstract_id = e.abstract_id\
                       JOIN mesh_descriptor md\
                       ON md.id = am.mesh_id\
                       JOIN titles t\
                       ON e.abstract_id = t.a\
                       WHERE md.id = %ld\
                       AND t.t MATCH '%@'\
                       ORDER BY e.title\
                       LIMIT 1\
                       OFFSET %ld", (unsigned long)meshId, [self tokenizeSearchString:str], (unsigned long)val];
    
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm = [self getTitleForId:(NSUInteger)[rs intForColumn:@"a"]];
    }
    return tm;

}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereJournalEquals:(NSUInteger)journalId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT e.abstract_id, e.journal_year, j.journal_abv, e.title\
                       FROM erpubtbl e\
                       JOIN journals j\
                       ON j.id = e.journal_id\
                       WHERE j.id = %ld\
                       ORDER BY e.title\
                       LIMIT 1\
                       OFFSET %ld", (unsigned long)journalId, (unsigned long)val];
    
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"abstract_id"];
        tm.year = [rs stringForColumn:@"journal_year"];
        tm.journal_abv = [rs stringForColumn:@"journal_abv"];
    }
    
    tm.descriptors = [self getMeshDescriptorsForId:tm.rowId];
    
    return tm;
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereJournalEquals:(NSUInteger)journalId andTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT t.a\
                       FROM erpubtbl e\
                       JOIN journals j\
                       ON j.id = e.journal_id\
                       JOIN titles t\
                       ON e.abstract_id = t.a\
                       WHERE j.id = %ld\
                       AND t.t MATCH '%@'\
                       ORDER BY e.title\
                       LIMIT 1\
                       OFFSET %ld", (unsigned long)journalId, [self tokenizeSearchString:str], (unsigned long)val];
    
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm = [self getTitleForId:(NSUInteger)[rs intForColumn:@"a"]];
    }
    return tm;

}

-(int)getTitleCount
{
    //count all rows
    FMResultSet *count = [self.db executeQuery:@"SELECT COUNT(*) FROM erpubtbl"];
    if ([count next]) {
        NSLog(@"Total Rows in erpubtbl: %d", [count intForColumnIndex:0]);
        return [count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(NSUInteger)getTitleCountWhereTitleMatch:(NSString*)str;
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM titles WHERE t MATCH '%@'", [self tokenizeSearchString:str]];
    NSLog(@"%@", query);
    
    FMResultSet *count = [self.db executeQuery:query];
    
    if ([count next]) {
        NSLog(@"Total Rows in titles: %d where title MATCH %@", [count intForColumnIndex:0], str);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(NSUInteger)getTitleCountWhereMeshEquals:(NSUInteger)meshId
{
    NSString *query = [NSString stringWithFormat:@"SELECT count(*)\
                       FROM erpubtbl e\
                       JOIN abstract_mesh am\
                       ON am.abstract_id = e.abstract_id\
                       JOIN mesh_descriptor md\
                       ON md.id = am.mesh_id\
                       WHERE md.id = %ld", (unsigned long)meshId];
    
    FMResultSet *count = [self.db executeQuery:query];

    if ([count next]) {
        NSLog(@"Total Rows in erpubtbl: %d", [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(NSUInteger)getTitleCountWhereMeshEquals:(NSUInteger)meshId andTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(*)\
                       FROM erpubtbl e\
                       JOIN abstract_mesh am\
                       ON am.abstract_id = e.abstract_id\
                       JOIN mesh_descriptor md\
                       ON md.id = am.mesh_id\
                       JOIN titles t on e.abstract_id = t.a\
                       WHERE md.id = %ld\
                       AND t.t MATCH '%@'", (unsigned long)meshId, [self tokenizeSearchString:str]];
    
    FMResultSet *count = [self.db executeQuery:query];
    
    if ([count next]) {
        NSLog(@"Total Rows in erpubtbl: %d", [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(NSUInteger)getTitleCountWhereJournalEquals:(NSUInteger)journalId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(*)\
                       FROM erpubtbl e\
                       JOIN journals j\
                       ON j.id = e.journal_id\
                       WHERE j.id = %ld", (unsigned long)journalId];
    
    FMResultSet *count = [self.db executeQuery:query];
    
    if ([count next]) {
        NSLog(@"Total Rows in erpubtbl: %d", [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(NSUInteger)getTitleCountWhereJournalEquals:(NSUInteger)journalId andTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(*)\
                       FROM erpubtbl e\
                       JOIN journals j\
                       ON j.id = e.journal_id\
                       JOIN titles t on e.abstract_id = t.a\
                       WHERE j.id = %ld\
                       AND t.t MATCH '%@'", (unsigned long)journalId, [self tokenizeSearchString:str]];
    
    FMResultSet *count = [self.db executeQuery:query];
    
    if ([count next]) {
        NSLog(@"Total Rows in erpubtbl: %d", [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}



#pragma mark PMIDs

-(NSString*)getPmidForId:(NSUInteger)emaId
{
    NSString *query = [NSString stringWithFormat: @"SELECT pmid FROM erpubtbl WHERE id = %ld", (long)emaId];
    FMResultSet *title = [self.db executeQuery:query];
    if ([title next]) {
        NSLog(@"stringForPMID: %@", [title stringForColumn:@"pmid"]);
        return [title stringForColumn:@"pmid"];
    }else{
        return @"";
    }
}

#pragma mark Descriptors

-(NLSDescriptorModel*)getDescriptorForRow:(NSUInteger)val whereSectionLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM mesh_descriptor WHERE name LIKE '%@%%' ORDER BY name COLLATE NOCASE LIMIT 1 OFFSET %ld", str, (unsigned long)val];
    FMResultSet *rs = [self.db executeQuery:query];
    NLSDescriptorModel *dm = [[NLSDescriptorModel alloc] init];
    
    if ([rs next]) {
        dm.name = [rs stringForColumn:@"name"];
        dm.rowId = (NSUInteger)[rs intForColumn:@"id"];
        NSLog(@"result Dict: %@", dm);
    }
    return dm;
}

#pragma mark Journals

-(NLSJournalModel*)getJournalTitleForRow:(NSUInteger)val whereSectionLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM journals WHERE journal_title LIKE '%@%%' ORDER BY journal_title COLLATE NOCASE LIMIT 1 OFFSET %ld", str, (unsigned long)val];
    FMResultSet *rs = [self.db executeQuery:query];
    NLSJournalModel *jm = [[NLSJournalModel alloc] init];
    
    if ([rs next]) {
        jm.journal_title = [rs stringForColumn:@"journal_title"];
        jm.rowId = (NSUInteger)[rs intForColumn:@"id"];
        NSLog(@"result Dict: %@", jm);
    }
    return jm;
}

#pragma mark Abstracts

-(NLSDetailModel*)getAbstractWithId:(NSUInteger)val
{

    FMResultSet *rs = [self.db executeQueryWithFormat:@"SELECT id, abstract FROM abstracts where id = %ld", (unsigned long)val];
    NLSDetailModel *dm = [[NLSDetailModel alloc] init];
    
    if ([rs next]) {
        dm.abstract = [NSString stringWithFormat: @"%s", [rs UTF8StringForColumnName:@"abstract"]];
        dm.rowId = (NSUInteger)[rs intForColumn:@"id"];
        NSLog(@"result DetailModel: %@", dm);
    }
    return dm;
}

#pragma mark Counts

-(NSUInteger)getCountFromTable:(NSString*)table
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM %@", table];
    
    NSLog(@"%@", query);
    FMResultSet *count = [self.db executeQuery:query];
    if ([count next]) {
        NSLog(@"Total Rows in %@: %d", table, [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
    
}

-(NSUInteger)getCountFromTable:(NSString*)table whereCol:(NSString*)col like:(NSString*)str{

    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM %@ WHERE %@ LIKE '%@'", table, col, str];
    
    NSLog(@"%@", query);
    
    FMResultSet *count = [self.db executeQuery:query];
    if ([count next]) {
        NSLog(@"Total Rows in %@: %d", table, [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
    
}

#pragma mark Unsafe

-(NLSTitleModel*)get:(NSString *)cols from:(NSString *)table forRow:(NSUInteger)val
{
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@ LIMIT 1 OFFSET %ld", cols, table, (long)val];
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"id"];
        NSLog(@"result Dict: %@", tm);
    }
    return tm;
}

-(NLSTitleModel*)get:(NSString *)cols from:(NSString *)table where:(NSString*)w like:(NSString*)l forRow:(NSUInteger)val
{
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ LIKE '%%%@%%' LIMIT 1 OFFSET %ld", cols, table, w, l, (long)val];
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"id"];
        NSLog(@"result Dict: %@", tm);
    }
    return tm;
}

@end

