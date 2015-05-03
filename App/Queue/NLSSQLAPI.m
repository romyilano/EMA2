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
    
    [queue inDatabase:^(FMDatabase *db) {
        [db makeFunctionNamed:@"CustomRank" maximumArguments:1 withBlock:^(sqlite3_context *context, int argc, sqlite3_value **argv) {
            if (argc != 1)
                sqlite3_result_null(context);
            if (sqlite3_value_type(argv[0]) == SQLITE_NULL)
                sqlite3_result_null(context);
            
            int weight = 0;
            //unsigned int *blob = (unsigned int *)sqlite3_value_blob(argv[0]);
            
//            unsigned int numberOfPhrases = blob[0];
//            unsigned int numberOfColumns = blob[1];
            
            // Ranking details left out.
            
            sqlite3_result_int(context, weight);
        }];
    }];
    
    [queue inDatabase:^(FMDatabase *db) {
        [db makeFunctionNamed:@"okapi_bm25" maximumArguments:2 withBlock:^(sqlite3_context *context, int argc, sqlite3_value **argv) {
            assert(sizeof(int) == 4);
            
            unsigned int *matchinfo = (unsigned int *)sqlite3_value_blob(argv[0]);
            int searchTextCol = sqlite3_value_int(argv[1]);
            
            double K1 = ((argc >= 3) ? sqlite3_value_double(argv[2]) : 1.2);
            double B = ((argc >= 4) ? sqlite3_value_double(argv[3]) : 0.75);
            
            int P_OFFSET = 0;
            int C_OFFSET = 1;
            int N_OFFSET = 2;
            int A_OFFSET = 3;
            
            int termCount = matchinfo[P_OFFSET];
            int colCount = matchinfo[C_OFFSET];
            
            int L_OFFSET = (A_OFFSET + colCount);
            int X_OFFSET = (L_OFFSET + colCount);
            
            double totalDocs = matchinfo[N_OFFSET];
            double avgLength = matchinfo[A_OFFSET + searchTextCol];
            double docLength = matchinfo[L_OFFSET + searchTextCol];
            
            double sum = 0.0;
            
            for (int i = 0; i < termCount; i++) {
                int currentX = X_OFFSET + (3 * searchTextCol * (i + 1));
                double termFrequency = matchinfo[currentX];
                double docsWithTerm = matchinfo[currentX + 2];
                
                double idf = log(
                                 (totalDocs - docsWithTerm + 0.5) /
                                 (docsWithTerm + 0.5)
                                 );
                
                double rightSide = (
                                    (termFrequency * (K1 + 1)) /
                                    (termFrequency + (K1 * (1 - B + (B * (docLength / avgLength)))))
                                    );
                
                sum += (idf * rightSide);
            }
            
            sqlite3_result_double(context, sum);
            
        }];
    }];
    
    [self checkRankFunction];
    [self checkOkapiFunction];
    
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
    NSLog(@"%@", NSStringFromSelector(_cmd));
    //Get associated mesh descriptors
    NSString *query = [NSString stringWithFormat:  @"SELECT am.mesh_id, m.name "
                                                   @"FROM abstract_mesh am "
                                                   @"JOIN mesh_descriptor m "
                                                   @"ON m.id = am.mesh_id "
                                                   @"WHERE am.pmid = "
                                                   @"(SELECT pmid FROM erpubtbl WHERE id = %ld)", (long)emaId];
    
    return [self getMeshArrayForSQL:query];
}

-(NLSTitleModel*)getTitleForId:(NSInteger)emaId
{
    NSString * query = [NSString stringWithFormat:@"SELECT e.id, e.pmid, e.title, e.journal_year, j.journal_abv "
                        "FROM erpubtbl e "
                        "JOIN journals j "
                        "ON e.journal_id = j.id "
                        "WHERE e.id = %ld "
                        "LIMIT 1", (long)emaId];

    return [self getTitleModelForSQL:query];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val
{
    NSString * query = [NSString stringWithFormat:  @"SELECT e.id, e.pmid, e.title, e.journal_year "
                                                    @"FROM erpubtbl e "
                                                    @"WHERE e.id =  %ld", (long)val];
    
    return [self getTitleModelForSQL:query];
}

-(NLSTitleModel*)getJournalAbvForId:(NSInteger)emaId
{

//    NSLog(@"journal abv id: %d", emaId);
    // SELECT e.journal_id, e.journal_year, j.journal_title FROM erpubtbl e JOIN journals j ON e.journal_id = j.id WHERE e.id = 1;
    NSString * query = [NSString stringWithFormat:  @"SELECT e.journal_id, e.journal_year, j.journal_title "
                        @"FROM erpubtbl e "
                        @"JOIN journals j "
                        @"ON e.journal_id = j.id "
                        @"WHERE e.id = %ld;", (long)emaId];
    
    return [self getTitleModelWithJournalAbreviationForSQL:query];

}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereTitleMatch:(NSString *)str
{
    NSLog(@"getTitleAndIdForRow: %ld where str: %@", (long)val, str);
    
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT t.a \
                       FROM erpubtbl e \
                       JOIN titles t \
                       ON e.id = t.a \
                       WHERE t.t MATCH '%@' \
                       ORDER BY e.journal_year DESC \
                       LIMIT 1 \
                       OFFSET %ld", [self tokenizeSearchString:str], (unsigned long)val];

    NSInteger myId = [self getIntForSQL:query];
    NSLog(@"myId: %ld", (long)myId);
    
    return [self getTitleForId:myId];
}

-(NLSTitleModel*)getTitleAndIdForRowOkapi:(NSInteger)val whereTitleMatch:(NSString *)str
{
    NSLog(@"getTitleAndIdForRowOkapi: %ld where str: %@", (long)val, str);
    //SELECT t FROM titles WHERE titles MATCH '%@' ORDER BY okapi_bm25(matchinfo(titles, \'pcnalx\'), 0) DESC;
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT a \
                       FROM titles \
                       WHERE titles MATCH '%@' \
                       ORDER BY okapi_bm25(matchinfo(titles, \'pcnalx\'), 0) DESC \
                       LIMIT 1 \
                       OFFSET %ld", [self tokenizeSearchString:str], (unsigned long)val];
    
    NSInteger myId = [self getIntForSQL:query];
    NSLog(@"myId: %ld", (long)myId);
    
    return [self getTitleForId:myId];
}

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereMeshEquals:(NSInteger)meshId
{
    NSString *query = [NSString stringWithFormat:@"\
                       SELECT e.id, e.pmid, e.title, e.journal_year, j.journal_abv \
                       FROM erpubtbl e \
                       JOIN abstract_mesh am \
                       ON am.pmid = e.pmid \
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
                       ON am.pmid = e.pmid \
                       JOIN mesh_descriptor md \
                       ON md.id = am.mesh_id \
                       JOIN titles t \
                       ON e.id = t.a \
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
                       SELECT e.id, e.pmid, e.journal_year, j.journal_abv, e.title \
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
                       ON e.id = t.a \
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
                       ON am.pmid = e.pmid \
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
                       ON am.pmid = e.pmid \
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

    NSString *query = [NSString stringWithFormat:@"SELECT a, t FROM titles WHERE a = %ld", (unsigned long)val];
    return [self getDetailModelForSQL:query];
}

#pragma mark Arrays

-(NSArray*)getTitleModelsForRange:(NSRange)range
{
    NSString *query = [NSString stringWithFormat:@"SELECT e.id, e.title, e.journal_year, e.pmid FROM erpubtbl e WHERE e.id BETWEEN %ld AND %ld", (unsigned long)range.location, (unsigned long)range.length];
    return [self getTitleModelArrayForSQL:query];
}

-(NSMutableArray*)getTitleModelArrayForSQL:(NSString*)sql
{
    
    NSLog(@"SQLAPI - getTitleModelArrayForSQL %@", sql);
    __block FMResultSet *rs = nil;
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    
    [self.queue inDatabase:^(FMDatabase *db) {

        rs = [db executeQuery:sql];
        while ([rs next]) {
            NLSTitleModel *tm = [[NLSTitleModel alloc] init];
            tm.title = [rs stringForColumn:@"title"];
            tm.year = [rs stringForColumn:@"journal_year"];
            tm.journal_abv = @"testing";
            tm.pmid = [rs intForColumn:@"pmid"];
            tm.rowId = [rs intForColumnIndex:0];
//            tm.data = [@"complete" dataUsingEncoding:NSUTF8StringEncoding];
            //NSLog(@"rowId: %ld", (long)tm.rowId);
            [array addObject:tm];
        }
        
        return;
    }];
    
//    for(NLSTitleModel *tm in array){
//        tm.descriptors = [self getMeshDescriptorsForId:tm.rowId];
//    }
    
    return array;
}

-(NSArray*)getTitleModelsForMatch:(NSString*)match
{
    NSString *query = [NSString stringWithFormat:@"SELECT a FROM titles WHERE t MATCH '%@'", [self tokenizeSearchString:match]];
    
    return [self getTitleIdsForSQL:query];
}

-(NSArray*)getTitleIdsForSQL:(NSString*)sql
{
    NSLog(@"SQLAPI %@ %@", NSStringFromSelector(_cmd), sql);
    __block FMResultSet *rs = nil;
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        rs = [db executeQuery:sql];
        while ([rs next]) {
            [array addObject:@([rs intForColumn:@"a"])];
        }
        
        return;
    }];
    
    return array;
}

-(NLSTitleModel*)getEmptyTitleModelWithDescriptorsForId:(NSInteger)emaId
{
//    NSLog(@"SQLAPI - %@ %d", NSStringFromSelector(_cmd), emaId);

    NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    tm.descriptors = [self getMeshDescriptorsForId:emaId];
    
    return tm;
}

#pragma mark QUEUE with SQL

-(NLSTitleModel*)getTitleModelForSQL:(NSString*)sql
{
    
    NSLog(@"SQLAPI %@", NSStringFromSelector(_cmd));
    __block FMResultSet *rs = nil;
    __block NLSTitleModel *tm = [[NLSTitleModel alloc] init];

    
    [self.queue inDatabase:^(FMDatabase *db) {

        rs = [db executeQuery:sql];
        while ([rs next]) {
            tm.title = [rs stringForColumn:@"title"];
            tm.year = [rs stringForColumn:@"journal_year"];
            tm.pmid = [rs intForColumn:@"pmid"];
            tm.rowId = [rs intForColumnIndex:0];
//            NSLog(@"rowId: %ld", (long)tm.rowId);
        }

        return;
    }];
    
    return tm;
}

-(NLSTitleModel*)getTitleModelWithJournalAbreviationForSQL:(NSString*)sql
{
    
    NSLog(@"SQLAPI %@", NSStringFromSelector(_cmd));
    __block FMResultSet *rs = nil;
    __block NLSTitleModel *tm = [[NLSTitleModel alloc] init];
    
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        rs = [db executeQuery:sql];
        while ([rs next]) {
            tm.journal_abv = [rs stringForColumn:@"journal_title"];
            tm.year = [rs stringForColumn:@"journal_year"];
        }
        
        return;
    }];
    
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
    
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), sql);
    __block FMResultSet *rs = nil;
    __block NLSDetailModel *dm = [[NLSDetailModel alloc] init];
    
    [self.queue inDatabase:^(FMDatabase *db) {

        rs = [db executeQuery:sql];
        while ([rs next]) {
            dm.abstract = [NSString stringWithFormat: @"%s", [rs UTF8StringForColumnName:@"t"]];
            dm.rowId = [rs intForColumnIndex:0];
        }

        return;
    }];
    
    NSLog(@"%@", dm);
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

-(void)checkRankFunction{

    __block FMResultSet *rs = nil;
    __block NSString *query = nil;
    
    [self.queue inDatabase:^(FMDatabase *db) {
        query = [NSString stringWithFormat:@"SELECT t FROM titles WHERE titles MATCH '%@' ORDER BY CustomRank(matchinfo(titles)) DESC;", @"baseball"];
        rs = [db executeQuery:query];
        while ([rs next]) {
            //NSLog(@"%d %@",[rs intForColumnIndex:0],[rs stringForColumn:@"t"]);
        }
        return;
    }];
}

-(void)checkOkapiFunction{
    
    __block FMResultSet *rs = nil;
    __block NSString *query = nil;
    
    NSLog(@"------------------------------------\n");
    
    [self.queue inDatabase:^(FMDatabase *db) {
        query = [NSString stringWithFormat:@"SELECT t FROM titles WHERE titles MATCH '%@' ORDER BY okapi_bm25(matchinfo(titles, \'pcnalx\'), 0) DESC;", @"baseball"];
        rs = [db executeQuery:query];
        while ([rs next]) {
            //NSLog(@"%d %@",[rs intForColumnIndex:0],[rs stringForColumn:@"t"]);
        }
        return;
    }];
}


@end

