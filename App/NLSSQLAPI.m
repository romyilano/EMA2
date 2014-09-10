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
@synthesize queue = _queue;
@synthesize favesQ = _favesQ;
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

    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    self.queue = queue;

    NSString *favesPath = [self.GetDocumentDirectory stringByAppendingPathComponent:@"emafaves.sqlite"];
    FMDatabaseQueue *favesQ = [FMDatabaseQueue databaseQueueWithPath:favesPath];
    self.favesQ = favesQ;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"faves exists: %d",[fileManager fileExistsAtPath:favesPath]);

    [self createFavoritesTable];
    
//    [self performSelectorInBackground:@selector(createTitles) withObject:nil];
//    [self performSelectorInBackground:@selector(createDescriptors) withObject:nil];
    
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
    
    NSString *query = @"CREATE TABLE IF NOT EXISTS favorites (id NUMBER, title TEXT);";
    
    [self runFavesSQL:query withLabel:@"Creating Faves Tables"];
}

#pragma mark Favorites

-(BOOL)insertIntoFavorites:(NSUInteger)emaId
{
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO favorites (id) VALUES (%ld) ", (unsigned long)emaId];
    
    return [self runFavesSQL:query withLabel:@"Inserting into Favorites"];
}

-(BOOL)deleteFavorites
{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM favorites"];

    return [self runFavesSQL:query withLabel:@"Deleting from Favorites"];
}

-(BOOL)deleteFromFavorites:(NSUInteger)emaId
{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM favorites WHERE id = %ld;", (unsigned long)emaId];
    
    return [self runFavesSQL:query withLabel:@"Deleting from Favorites"];
}

-(BOOL)checkForFavoriteId:(NSUInteger)emaId
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM favorites WHERE id = %ld;", (unsigned long)emaId];
    NSLog(@" faves query %@", query);
    return (BOOL)[self getFavesIntForSQL:query];
}

-(NLSTitleModel*)getFavoriteForRow:(NSUInteger)val
{
    NSString *query = [NSString stringWithFormat:@"SELECT id FROM favorites LIMIT 1 OFFSET %ld", (long)val];
    NSUInteger emaId = [self getFavesIntForSQL:query];
    return [self getTitleForId:emaId];
}

-(NSUInteger)getCountFromFavorites
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM favorites"];
    NSLog(@"%@", query);
    
    return [self getFavesIntForSQL:query];
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

-(NSString*)getTitleWhereId:(NSUInteger)emaId
{
    NSString *query = [NSString stringWithFormat: @"SELECT title FROM erpubtbl WHERE id = %ld", (long)emaId];
    
    return [self getStringForSQL:query];
}

-(NSArray *)getMeshDescriptorsForId:(NSUInteger)emaId
{
    //Get associated mesh descriptors
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT a.mesh_id, m.name\
                       FROM erpubtbl e\
                       JOIN abstract_mesh a\
                       ON a.abstract_id = e.id\
                       JOIN mesh_descriptor m\
                       ON m.id = a.mesh_id\
                       WHERE e.id = %ld", (unsigned long)emaId];
    
    return [self getMeshArrayForSQL:query];
}


-(NLSTitleModel*)getTitleForId:(NSUInteger)emaId
{
    NSString * query = [NSString stringWithFormat:@"SELECT e.id, e.title, e.journal_year, j.journal_abv "
                        "FROM erpubtbl e "
                        "JOIN journals j "
                        "ON e.journal_id = j.id "
                        "WHERE e.id = %ld "
                        "LIMIT 1", (long)emaId];

    return [self getTitleModelForSQL:query];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val
{
    NSString * query = [NSString stringWithFormat:@"\
                        SELECT e.id, e.title, e.journal_year, j.journal_abv\
                        FROM erpubtbl e\
                        JOIN journals j\
                        ON e.journal_id = j.id\
                        LIMIT 1 OFFSET %ld;", (long)val];
    
    return [self getTitleModelForSQL:query];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereTitleMatch:(NSString *)str
{
    
    NSString *query = [NSString stringWithFormat:@"SELECT a "
                       "FROM titles "
                       "WHERE t MATCH '%@' "
                       "ORDER BY t "
                       "LIMIT 1 "
                       "OFFSET %ld", [self tokenizeSearchString:str], (unsigned long)val];

    NSUInteger myId = [self getIntForSQL:query];
    return [self getTitleForId:myId];
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
    
    NSLog(@"get title and id for row where mesh = %@", query);
    return [self getTitleModelForSQL:query];
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
    
    NSUInteger myId = [self getIntForSQL:query];
    return [self getTitleForId:myId];

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
    
    return [self getTitleModelForSQL:query];
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
    
    NSUInteger myId = [self getIntForSQL:query]; //get id first
    return [self getTitleForId:myId];
}

-(NSUInteger)getTitleCount
{

    NSString *query = [NSString stringWithFormat:@"SELECT count(0) FROM titles"];

    return [self getCountForSQL:query];
}


-(NSUInteger)getTitleCountWhereTitleMatch:(NSString*)str;
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM titles WHERE t MATCH '%@'", [self tokenizeSearchString:str]];

    return [self getCountForSQL:query];
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
    
    return [self getCountForSQL:query];
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
    
    return[self getCountForSQL:query];
}

-(NSUInteger)getTitleCountWhereJournalEquals:(NSUInteger)journalId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(*)\
                       FROM erpubtbl e\
                       JOIN journals j\
                       ON j.id = e.journal_id\
                       WHERE j.id = %ld", (unsigned long)journalId];
    
    return [self getCountForSQL:query];
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
    
    return[self getCountForSQL:query];
}

#pragma mark PMIDs

-(NSString*)getPmidForId:(NSUInteger)emaId
{
    NSString *query = [NSString stringWithFormat: @"SELECT pmid FROM erpubtbl WHERE id = %ld", (long)emaId];

    return [self getStringForSQL:query];
}

#pragma mark Descriptors

-(NSUInteger)getCountFromDescriptorsWhereSectionLike:str
{
    NSString *query = [NSString stringWithFormat:@"\
                                            SELECT count(0)\
                                            FROM mesh_descriptor\
                                            WHERE name\
                                            LIKE '%@%%'", str];
    return [self getCountForSQL:query];
}


-(NLSDescriptorModel*)getDescriptorForRow:(NSUInteger)val whereSectionLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT *\
                       FROM mesh_descriptor m\
                       WHERE name LIKE '%@%%'\
                       ORDER BY name\
                       COLLATE NOCASE\
                       LIMIT 1 OFFSET %ld", str, (unsigned long)val];

    return [self getDescriptorModelForSQL:query];
}

#pragma mark Journals

-(NSUInteger)getCountFromJournalsWhereSectionLike:str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(0)\
                       FROM journals\
                       WHERE journal_title\
                       LIKE '%@%%'", str];
    return [self getCountForSQL:query];
}

-(NLSJournalModel*)getJournalTitleForRow:(NSUInteger)val whereSectionLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:   @"SELECT * FROM "
                                                    @"journals "
                                                    @"WHERE journal_title LIKE '%@%%' "
                                                    @"ORDER BY journal_title "
                                                    @"COLLATE NOCASE "
                                                    @"LIMIT 1 OFFSET %ld", str, (unsigned long)val];
    
    return [self getJournalModelForSQL:query];
}

#pragma mark Abstracts

-(NLSDetailModel*)getAbstractWithId:(NSUInteger)val
{

    NSString *query = [NSString stringWithFormat:@"SELECT id, abstract FROM abstracts WHERE id = %ld", (unsigned long)val];
    return [self getDetailModelForSQL:query];
}


#pragma mark QUEUE with SQL

-(NLSTitleModel*)getTitleModelForSQL:(NSString*)sql
{
    
    __block FMResultSet *rs = nil;
    __block NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while ([rs next]) {
            tm.title = [rs stringForColumn:@"title"];
            tm.year = [rs stringForColumn:@"journal_year"];
            tm.journal_abv = [rs stringForColumn:@"journal_abv"];
            tm.rowId = (NSUInteger)[rs intForColumnIndex:0];
        }
        return;
    }];
    
    tm.descriptors = [self getMeshDescriptorsForId:tm.rowId];
    return tm;
}

-(NLSDescriptorModel*)getDescriptorModelForSQL:(NSString*)sql
{
    
    NSLog(@"get descriptor model for sql");
    __block FMResultSet *rs = nil;
    __block NLSDescriptorModel *dm = [[NLSDescriptorModel alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while ([rs next]) {
            dm.name = [rs stringForColumn:@"name"];
            dm.rowId = (NSUInteger)[rs intForColumnIndex:0];
        }
        return;
    }];
    
    return dm;
}

-(NLSDetailModel*)getDetailModelForSQL:(NSString*)sql
{
    
    NSLog(@"get descriptor model for sql");
    __block FMResultSet *rs = nil;
    __block NLSDetailModel *dm = [[NLSDetailModel alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while ([rs next]) {
            dm.abstract = [NSString stringWithFormat: @"%s", [rs UTF8StringForColumnName:@"abstract"]];
            dm.rowId = (NSUInteger)[rs intForColumnIndex:0];
        }
        return;
    }];
    
    return dm;
}

-(NLSJournalModel*)getJournalModelForSQL:(NSString*)sql
{
    
    NSLog(@"get descriptor model for sql");
    __block FMResultSet *rs = nil;
    __block NLSJournalModel *jm = [[NLSJournalModel alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while ([rs next]) {
            jm.journal_title = [rs stringForColumn:@"journal_title"];
            jm.rowId = (NSUInteger)[rs intForColumnIndex:0];
        }
        return;
    }];
    
    return jm;
}


-(NSUInteger)getCountForSQL:sql
{
    __block FMResultSet *rs = nil;
    __block NSUInteger count = 0;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        if ([rs next]) {
            count = (NSUInteger)[rs intForColumnIndex:0];
        }else{
            count = 0;
        }
        return;
    }];
    
    NSLog(@"count result: %ld", (unsigned long)count);
    return count;
    
}

-(NSString*)getStringForSQL:sql
{

    __block FMResultSet *rs = nil;
    __block NSString *str = nil;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        if ([rs next]) {
            str = [rs stringForColumnIndex:0];
        }else{
            str = @"";
        }
        return;
    }];
    return str;
}

-(NSUInteger)getIntForSQL:sql
{
    __block FMResultSet *rs = nil;
    __block NSUInteger myInt = 3;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        if ([rs next]) {
            myInt = (NSUInteger)[rs intForColumnIndex:0];
        }
        return;
    }];
    return myInt;
}


-(NSArray *)getMeshArrayForSQL:sql
{
    
    __block FMResultSet *rs = nil;
    __block NSMutableArray *mesh_array = [[NSMutableArray alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while ([rs next]) {
            [mesh_array addObject:[rs stringForColumn:@"name"]];
        }
        return;
    }];
    
    return [NSArray arrayWithArray:(NSArray*)mesh_array];
}

-(void)executeInQueueWithSQL:(NSString*)sql withLabel:(NSString*)label
{
    __block BOOL success = 0;
    
    [self.queue inDatabase:^(FMDatabase *db){
        success = [db executeStatements:sql];
        NSLog(@"%@ Success: %d", label, success);
    }];
    
}

-(BOOL)runFavesSQL:(NSString*)sql withLabel:(NSString*)label
{
    __block BOOL success = 0;
    
    [self.favesQ inDatabase:^(FMDatabase *db){
        success = [db executeStatements:sql];
        return;
    }];
    
    NSLog(@"%@ Success: %d", label, success);
    return success;
    
}


-(NSUInteger)getFavesIntForSQL:sql
{
    __block FMResultSet *rs = nil;
    __block NSUInteger myInt = 0;
    
    [self.favesQ inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        if ([rs next]) {
            myInt = (NSUInteger)[rs intForColumnIndex:0];
        }
        return;
    }];
    return myInt;
}


-(NLSTitleModel*)getTitleModelFromFavesForSQL:(NSString*)sql
{
    
    __block FMResultSet *rs = nil;
    __block NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    [self.favesQ inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while ([rs next]) {
            tm.title = [rs stringForColumn:@"title"];
            tm.rowId = (NSUInteger)[rs intForColumnIndex:0];
        }
        return;
    }];
    
    return tm;
}



@end

