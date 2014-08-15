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
@synthesize favesDb = _favesDb;
@synthesize someProperty;
@synthesize fileMgr = _fileMgr;
@synthesize homeDir = _homeDir;


#pragma mark Singleton Methods

+ (id)sharedManager {
    static NLSSQLAPI *sqlAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlAPI = [[self alloc] init];
    });
    return sqlAPI;
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
        [self initDatabase];
    }
    return self;
}

- (void) initDatabase
{
    
    NSString *path = [self.GetDocumentDirectory stringByAppendingPathComponent:@"ema.sqlite"];
    FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
    self.db = fmdb;


    NSString *favesPath = [self.GetDocumentDirectory stringByAppendingPathComponent:@"emafaves.sqlite"];
    FMDatabase *favesDb = [FMDatabase databaseWithPath:favesPath];
    self.favesDb = favesDb;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"faves exists: %d",[fileManager fileExistsAtPath:favesPath]);

    
    if (![self.db open]) {
        NSLog(@"db not open");
        return;
    }else{
        [self createFTSTable];
    }
    
    if (![self.favesDb open]) {
        NSLog(@"faves db not open");
        return;
    }else{
        [self createFavoritesTable];
    }
    
    
}

-(NSString *)GetDocumentDirectory{
    self.fileMgr = [NSFileManager defaultManager];
    self.homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return self.homeDir;
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

-(void)createFTSTable
{
    NSLog(@"Creating FTS table");
    
    NSString *sql =     @"DROP TABLE IF EXISTS titles;"
                        @"CREATE VIRTUAL TABLE IF NOT EXISTS titles USING fts4(abstract_id, title);"
                        @"INSERT INTO titles SELECT abstract_id, title FROM erpubtbl;";
    BOOL success = [self.db executeStatements:sql];
    NSLog(@"FTS Success: %d", success);
}


-(void)createFavoritesTable
{

    NSLog(@"Creating Favorites table");
    
    NSString *sql = @"CREATE TABLE IF NOT EXISTS favorites (id, title);";
    
    BOOL success = [self.favesDb executeStatements:sql];
    NSLog(@"FTS Success: %d", success);
}

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
        return [count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(NSUInteger)getTitleCountWhereTitleContains:(NSString*)str
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM titles WHERE title MATCH '%@'", str];
    NSLog(@"%@", query);
    
    FMResultSet *count = [self.db executeQuery:query];
    
    if ([count next]) {
//        NSLog(@"Total Rows in titles: %d where title MATCH %@", [count intForColumnIndex:0], str);
        return [count intForColumnIndex:0];
    }else{
        return 0;
    }
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

-(NSString*)getTitleForId:(NSInteger)val
{
    FMResultSet *title = [self.db executeQueryWithFormat:@"SELECT title FROM erpubtbl LIMIT 1 OFFSET %ld", (long)val];
    if ([title next]) {
        //        NSString *title = [limitTen stringForColumn: @"title"];
        //        NSLog(@"Title col in erpubtbl: %@", title);
        NSLog(@"stringForTitle: %@", [title stringForColumn:@"title"]);
        return [title stringForColumn:@"title"];
    }else{
        return @"No title";
    }
}

-(NSString*)getTitleWhereId:(NSInteger)emaId
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

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val
{
    FMResultSet *rs = [self.db executeQueryWithFormat:@"SELECT id, title FROM erpubtbl LIMIT 1 OFFSET %ld", (long)val];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"id"];
        NSLog(@"result Dict: %@", tm);
    }
    return tm;
}

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

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"SELECT title, abstract_id\
                                                FROM titles\
                                                WHERE title\
                                                MATCH '%@'\
                                                ORDER BY title\
                                                LIMIT 1\
                                                OFFSET %ld", str, (unsigned long)val];
    NSLog(@"%@", query);
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"abstract_id"];
    }
    return tm;
}


-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereMeshEquals:(NSUInteger)meshId
{
    NSString *query = [NSString stringWithFormat:@"SELECT e.abstract_id,\
                       e.title\
                       FROM erpubtbl e\
                       JOIN abstract_mesh am\
                       ON am.abstract_id = e.abstract_id\
                       JOIN mesh_descriptor md\
                       ON md.id = am.mesh_id\
                       WHERE md.id = %ld\
                       ORDER BY e.title\
                       LIMIT 1\
                       OFFSET %ld", (unsigned long)meshId, (unsigned long)val];
    
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"abstract_id"];
        NSLog(@"result Dict: %@", tm);
    }
    return tm;
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereMeshEquals:(NSUInteger)meshId andTitleLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"SELECT e.abstract_id,\
                       e.title\
                       FROM erpubtbl e\
                       JOIN abstract_mesh am\
                       ON am.abstract_id = e.abstract_id\
                       JOIN mesh_descriptor md\
                       ON md.id = am.mesh_id\
                       WHERE md.id = %ld\
                       AND e.title LIKE '%%%@%%'\
                       ORDER BY e.title\
                       LIMIT 1\
                       OFFSET %ld", (unsigned long)meshId, str, (unsigned long)val];
    
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"abstract_id"];
        NSLog(@"result Dict: %@", tm);
    }
    return tm;
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
    NSString *query = [NSString stringWithFormat:@"SELECT count(*)\
                       FROM erpubtbl e\
                       JOIN abstract_mesh am\
                       ON am.abstract_id = e.abstract_id\
                       JOIN mesh_descriptor md\
                       ON md.id = am.mesh_id\
                       WHERE md.id = %ld\
                       AND e.title LIKE '%%%@%%'", (unsigned long)meshId, str];
    
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

-(NSUInteger)getTitleCountWhereJournalEquals:(NSUInteger)journalId andTitleLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(*)\
                       FROM erpubtbl e\
                       JOIN journals j\
                       ON j.id = e.journal_id\
                       WHERE j.id = %ld\
                       AND e.title LIKE '%%%@%%'", (unsigned long)journalId, str];
    
    FMResultSet *count = [self.db executeQuery:query];
    
    if ([count next]) {
        NSLog(@"Total Rows in erpubtbl: %d", [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereJournalEquals:(NSUInteger)journalId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT e.abstract_id,\
                       e.title\
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
    }
    return tm;
}


-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereJournalEquals:(NSUInteger)journalId andTitleLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT e.abstract_id,\
                       e.title\
                       FROM erpubtbl e\
                       JOIN journals j\
                       ON j.id = e.journal_id\
                       WHERE j.id = %ld\
                       AND e.title LIKE '%%%@%%'\
                       ORDER BY e.title\
                       LIMIT 1\
                       OFFSET %ld", (unsigned long)journalId, str, (unsigned long)val];
    
    FMResultSet *rs = [self.db executeQuery:query];
    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    if ([rs next]) {
        tm.title = [rs stringForColumn:@"title"];
        tm.rowId = (NSUInteger)[rs intForColumn:@"abstract_id"];
    }
    return tm;
}

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

@end

