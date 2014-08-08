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
}
@end

@implementation NLSSQLAPI

@synthesize tableArray = _tableArray;
@synthesize db = _db;

- (void) initDatabase
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ema" ofType:@"sqlite"];
    
    FMDatabase *fmdb = [FMDatabase databaseWithPath:path];
    self.db = fmdb;
    
    if (![self.db open]) {
        NSLog(@"db not open");
        return;
    }
    
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
                       OFFSET %ld", meshId, val];
    
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
                       WHERE md.id = %ld", meshId];
    
    FMResultSet *count = [self.db executeQuery:query];

    if ([count next]) {
        NSLog(@"Total Rows in erpubtbl: %d", [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
}

-(NLSDescriptorModel*)getDescriptorForRow:(NSUInteger)val whereSectionLike:(NSString *)str
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM mesh_descriptor WHERE name LIKE '%@%%' ORDER BY name COLLATE NOCASE LIMIT 1 OFFSET %ld", str, val];
    FMResultSet *rs = [self.db executeQuery:query];
    NLSDescriptorModel *dm = [[NLSDescriptorModel alloc] init];
    
    if ([rs next]) {
        dm.name = [rs stringForColumn:@"name"];
        dm.rowId = (NSUInteger)[rs intForColumn:@"id"];
        NSLog(@"result Dict: %@", dm);
    }
    return dm;
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

-(NSUInteger)getCountFromTable:(NSString*)table whereCol:(NSString*)col like:(NSString*)str{
    
    NSLog(@"table: %@, col: %@, like: %@", table, col, str);

    NSString *query = [NSString stringWithFormat:@"SELECT COUNT(0) FROM %@ WHERE %@ LIKE '%@'", table, col, str];
    
    FMResultSet *count = [self.db executeQuery:query];
    if ([count next]) {
        NSLog(@"Total Rows in %@: %d", table, [count intForColumnIndex:0]);
        return (NSUInteger)[count intForColumnIndex:0];
    }else{
        return 0;
    }
    
}

@end

