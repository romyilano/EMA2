//
//  NLSSQLAPI.m
//  App
//
//  Created by Amir on 7/23/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import "NLSSQLAPI.h"


@implementation NLSSQLAPI

@synthesize queue = _queue;
@synthesize favesQ = _favesQ;
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
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ema.sqlite"];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    self.queue = queue;

    NSString *favesPath = [self.GetDocumentDirectory stringByAppendingPathComponent:@"emafaves.sqlite"];
    FMDatabaseQueue *favesQ = [FMDatabaseQueue databaseQueueWithPath:favesPath];
    self.favesQ = favesQ;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSLog(@"erpubdb exists: %d",[fileManager fileExistsAtPath:path]);
    NSLog(@"faves exists: %d",[fileManager fileExistsAtPath:favesPath]);

    [self createFavoritesTable];
    
}

#pragma mark Create

-(void)createFavoritesTable
{
    
    NSString *query = @"CREATE TABLE IF NOT EXISTS favorites (id NUMBER, title TEXT);";
    
    [self runFavesSQL:query withLabel:@"Creating Faves Tables"];
}

#pragma mark Favorites

-(BOOL)insertIntoFavorites:(NSInteger)emaId
{
    
    NSString *query = [NSString stringWithFormat:@"INSERT INTO favorites (id) VALUES (%ld) ", (unsigned long)emaId];
    
    return [self runFavesSQL:query withLabel:@"Inserting into Favorites"];
}

-(BOOL)deleteFavorites
{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM favorites"];

    return [self runFavesSQL:query withLabel:@"Deleting from Favorites"];
}

-(BOOL)deleteFromFavorites:(NSInteger)emaId
{
    NSString *query = [NSString stringWithFormat:@"DELETE FROM favorites WHERE id = %ld;", (unsigned long)emaId];
    
    return [self runFavesSQL:query withLabel:@"Deleting from Favorites"];
}

-(BOOL)checkForFavoriteId:(NSInteger)emaId
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM favorites WHERE id = %ld;", (unsigned long)emaId];
    NSLog(@" faves query %@", query);
    return (BOOL)[self getFavesIntForSQL:query];
}

-(NLSTitleModel*)getFavoriteForRow:(NSInteger)val
{
    NSString *query = [NSString stringWithFormat:@"SELECT id FROM favorites LIMIT 1 OFFSET %ld", (long)val];
    NSInteger emaId = [self getFavesIntForSQL:query];
    return [self getTitleForId:emaId];
}

-(NSInteger)getCountFromFavorites
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

-(NSString*)getTitleWhereId:(NSInteger)emaId
{
    NSString *query = [NSString stringWithFormat: @"SELECT title FROM erpubtbl WHERE id = %ld", (long)emaId];
    
    return [self getStringForSQL:query];
}

-(NSArray *)getMeshDescriptorsForId:(NSInteger)emaId
{
    
    //Get associated mesh descriptors
    NSString *query = [NSString stringWithFormat:  @"SELECT a.mesh_id, m.name "
                                                   @"FROM abstract_mesh a "
                                                   @"JOIN mesh_descriptor m "
                                                   @"ON m.id = a.mesh_id "
                                                   @"WHERE a.abstract_id = %ld", (long)emaId];
    
    return [self getMeshArrayForSQL:query];
}

-(NLSTitleModel*)getTitleForId:(NSInteger)emaId
{
    NSString * query = [NSString stringWithFormat:@"SELECT e.id, e.title, e.journal_year, j.journal_abv "
                        "FROM erpubtbl e "
                        "JOIN journals j "
                        "ON e.journal_id = j.id "
                        "WHERE e.id = %ld "
                        "LIMIT 1", (long)emaId];

    return [self getTitleModelForSQL:query];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val
{
    NSString * query = [NSString stringWithFormat:  @"SELECT e.id, e.title, e.journal_year, j.journal_abv "
                                                    @"FROM erpubtbl e "
                                                    @"JOIN journals j "
                                                    @"ON e.journal_id = j.id "
                                                    @"ORDER BY e.journal_year DESC "
                                                    @"LIMIT 1 "
                                                    @"OFFSET %ld;", (long)val];
    
    return [self getTitleModelForSQL:query];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereTitleMatch:(NSString *)str
{
    NSLog(@"getTitleAndIdForRow: %ld where str: %@", (long)val, str);
    
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT t.a \
                       FROM erpubtbl e \
                       JOIN titles t \
                       ON e.abstract_id = t.a \
                       WHERE t.t MATCH '%@' \
                       ORDER BY e.journal_year DESC \
                       LIMIT 1 \
                       OFFSET %ld", [self tokenizeSearchString:str], (unsigned long)val];

    NSInteger myId = [self getIntForSQL:query];
    NSLog(@"myId: %ld", (long)myId);
    
    return [self getTitleForId:myId];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereMeshEquals:(NSInteger)meshId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT e.abstract_id, e.title, e.journal_year, j.journal_abv \
                       FROM erpubtbl e \
                       JOIN abstract_mesh am \
                       ON am.abstract_id = e.abstract_id \
                       JOIN mesh_descriptor md \
                       ON md.id = am.mesh_id \
                       JOIN journals j \
                       ON e.journal_id = j.id \
                       WHERE md.id = %ld \
                       ORDER BY e.journal_year DESC \
                       LIMIT 1 \
                       OFFSET %ld", (unsigned long)meshId, (unsigned long)val];
    
    NSLog(@"get title and id for row where mesh = %@", query);
    return [self getTitleModelForSQL:query];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereMeshEquals:(NSInteger)meshId andTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT t.a \
                       FROM erpubtbl e \
                       JOIN abstract_mesh am \
                       ON am.abstract_id = e.abstract_id \
                       JOIN mesh_descriptor md \
                       ON md.id = am.mesh_id \
                       JOIN titles t \
                       ON e.abstract_id = t.a \
                       WHERE md.id = %ld \
                       AND t.t MATCH '%@' \
                       ORDER BY e.journal_year DESC \
                       LIMIT 1 \
                       OFFSET %ld", (unsigned long)meshId, [self tokenizeSearchString:str], (unsigned long)val];
    
    NSInteger myId = [self getIntForSQL:query];
    return [self getTitleForId:myId];

}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereJournalEquals:(NSInteger)journalId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT e.abstract_id, e.journal_year, j.journal_abv, e.title \
                       FROM erpubtbl e \
                       JOIN journals j \
                       ON j.id = e.journal_id \
                       WHERE j.id = %ld \
                       ORDER BY e.journal_year DESC \
                       LIMIT 1 \
                       OFFSET %ld", (unsigned long)journalId, (unsigned long)val];
    
    return [self getTitleModelForSQL:query];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereJournalEquals:(NSInteger)journalId andTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT t.a \
                       FROM erpubtbl e \
                       JOIN journals j \
                       ON j.id = e.journal_id \
                       JOIN titles t \
                       ON e.abstract_id = t.a \
                       WHERE j.id = %ld \
                       AND t.t MATCH '%@' \
                       ORDER BY e.journal_year DESC \
                       LIMIT 1 \
                       OFFSET %ld", (unsigned long)journalId, [self tokenizeSearchString:str], (unsigned long)val];
    
    NSInteger myId = [self getIntForSQL:query]; //get id first
    return [self getTitleForId:myId];
}

-(NSInteger)getTitleCount
{

    NSString *query = [NSString stringWithFormat:@"SELECT count(0) FROM titles"];

    return [self getCountForSQL:query];
}

-(NSInteger)getTitleCountWhereTitleMatch:(NSString*)str;
{
    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM titles WHERE t MATCH '%@'", [self tokenizeSearchString:str]];

    return [self getCountForSQL:query];
}

-(NSInteger)getTitleCountWhereMeshEquals:(NSInteger)meshId
{
    NSString *query = [NSString stringWithFormat:@"SELECT count(*) \
                       FROM erpubtbl e \
                       JOIN abstract_mesh am \
                       ON am.abstract_id = e.abstract_id \
                       JOIN mesh_descriptor md \
                       ON md.id = am.mesh_id \
                       WHERE md.id = %ld", (unsigned long)meshId];
    
    return [self getCountForSQL:query];
}

-(NSInteger)getTitleCountWhereMeshEquals:(NSInteger)meshId andTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(*) \
                       FROM erpubtbl e \
                       JOIN abstract_mesh am \
                       ON am.abstract_id = e.abstract_id \
                       JOIN mesh_descriptor md \
                       ON md.id = am.mesh_id \
                       JOIN titles t on e.abstract_id = t.a \
                       WHERE md.id = %ld \
                       AND t.t MATCH '%@'", (unsigned long)meshId, [self tokenizeSearchString:str]];
    
    return [self getCountForSQL:query];
}

-(NSInteger)getTitleCountWhereJournalEquals:(NSInteger)journalId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(*) \
                       FROM erpubtbl e \
                       JOIN journals j \
                       ON j.id = e.journal_id \
                       WHERE j.id = %ld", (unsigned long)journalId];
    
    return [self getCountForSQL:query];
}

-(NSInteger)getTitleCountWhereJournalEquals:(NSInteger)journalId andTitleMatch:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@" \
                       SELECT count(*) \
                       FROM erpubtbl e \
                       JOIN journals j \
                       ON j.id = e.journal_id \
                       JOIN titles t on e.abstract_id = t.a \
                       WHERE j.id = %ld \
                       AND t.t MATCH '%@'", (unsigned long)journalId, [self tokenizeSearchString:str]];
    
    return [self getCountForSQL:query];
}

#pragma mark PMIDs

-(NSString*)getPmidForId:(NSInteger)emaId
{
    NSString *query = [NSString stringWithFormat: @"SELECT pmid FROM erpubtbl WHERE id = %ld", (long)emaId];

    return [self getStringForSQL:query];
}

#pragma mark Descriptors

-(NSString*)getMeshForId:(NSInteger)meshId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT name \
                       FROM mesh_descriptor \
                       WHERE id = %ld", (unsigned long)meshId];
    return [self getStringForSQL:query];
}

-(NSInteger)getCountFromDescriptorsWhereSectionLike:str
{
    NSString *query = [NSString stringWithFormat:@"\
                                            SELECT count(0) \
                                            FROM mesh_descriptor \
                                            WHERE name \
                                            LIKE '%@%%'", str];
    return [self getCountForSQL:query];
}

-(NLSDescriptorModel*)getDescriptorForRow:(NSInteger)val whereSectionLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT * \
                       FROM mesh_descriptor m \
                       WHERE name LIKE '%@%%' \
                       ORDER BY name \
                       COLLATE NOCASE \
                       LIMIT 1 OFFSET %ld", str, (unsigned long)val];

    return [self getDescriptorModelForSQL:query];
}

#pragma mark Journals

-(NSInteger)getCountFromJournalsWhereSectionLike:str
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT count(0) \
                       FROM journals \
                       WHERE journal_title \
                       LIKE '%@%%'", str];
    return [self getCountForSQL:query];
}

-(NLSJournalModel*)getJournalTitleForRow:(NSInteger)val whereSectionLike:(NSString *)str
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

-(NLSDetailModel*)getAbstractWithId:(NSInteger)val
{

    NSString *query = [NSString stringWithFormat:@"SELECT id, abstract FROM abstracts WHERE id = %ld", (unsigned long)val];
    return [self getDetailModelForSQL:query];
}


#pragma mark QUEUE with SQL

-(NLSTitleModel*)getTitleModelForSQL:(NSString*)sql
{
    
    NSLog(@"SQLAPI - getTitleModelForSQL %@", sql);
    __block FMResultSet *rs = nil;
    __block NLSTitleModel *tm = [[NLSTitleModel alloc] init];

    
    [self.queue inDatabase:^(FMDatabase *db) {

        rs = [db executeQuery:sql];
        while ([rs next]) {
            tm.title = [rs stringForColumn:@"title"];
            tm.year = [rs stringForColumn:@"journal_year"];
            tm.journal_abv = [rs stringForColumn:@"journal_abv"];
            tm.rowId = [rs intForColumnIndex:0];
            NSLog(@"rowId: %ld", (long)tm.rowId);
        }

        return;
    }];
    
    tm.descriptors = [self getMeshDescriptorsForId:tm.rowId];
    tm.data = [@"complete" dataUsingEncoding:NSUTF8StringEncoding];
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
            dm.rowId = [rs intForColumnIndex:0];
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
            dm.rowId = [rs intForColumnIndex:0];
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
            jm.issn = [rs stringForColumn:@"issn"];
            jm.rowId = [rs intForColumnIndex:0];
        }

        return;
    }];
    
    return jm;
}

-(NSInteger)getCountForSQL:sql
{
    __block FMResultSet *rs = nil;
    __block NSInteger count = 0;
    
    [self.queue inDatabase:^(FMDatabase *db) {

        rs = [db executeQuery:sql];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
        }

        return;
    }];
    
    return count;
    
}

-(NSString*)getStringForSQL:sql
{

    __block FMResultSet *rs = nil;
    __block NSString *str = @"";
    
    [self.queue inDatabase:^(FMDatabase *db) {

        rs = [db executeQuery:sql];
        while ([rs next]) {
            str = [rs stringForColumnIndex:0];
        }

        return;
    }];
    return str;
}

-(NSInteger)getIntForSQL:sql
{
    __block FMResultSet *rs = nil;
    __block NSInteger myInt = 3;
    
    [self.queue inDatabase:^(FMDatabase *db) {

        rs = [db executeQuery:sql];
        while ([rs next]) {
            myInt = [rs intForColumnIndex:0];
        }

        return;
    }];
    return myInt;
}

-(NSArray *)getMeshArrayForSQL:sql
{
    
    NSLog(@"SQLAPI - getMeshArrayForSQL %@", sql);
    __block FMResultSet *rs = nil;
    __block NSMutableArray *mesh_array = [[NSMutableArray alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        rs = [db executeQuery:sql];
        while ([rs next]) {
            [mesh_array addObject:@{
                                    @"id" : [NSNumber numberWithInt:[rs intForColumn:@"mesh_id"]],
                                    @"name" :[rs stringForColumn:@"name"]
                                    }];
        }
        return;
    }];
    
    return [NSArray arrayWithArray:(NSArray*)mesh_array];
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

-(NSInteger)getFavesIntForSQL:sql
{
    __block FMResultSet *rs = nil;
    __block NSInteger myInt = 0;
    
    [self.favesQ inDatabase:^(FMDatabase *db) {

        rs = [db executeQuery:sql];
        while ([rs next]) {
            myInt = [rs intForColumnIndex:0];
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
            tm.rowId = [rs intForColumnIndex:0];
        }

        return;
    }];
    
    return tm;
}



@end

