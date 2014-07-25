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
    FMResultSet *title = [self.db executeQueryWithFormat:@"SELECT title FROM erpubtbl LIMIT 1 OFFSET %ld", val];
    if ([title next]) {
        //        NSString *title = [limitTen stringForColumn: @"title"];
        //        NSLog(@"Title col in erpubtbl: %@", title);
        NSLog(@"stringForTitle: %@", [title stringForColumn:@"title"]);
        return [title stringForColumn:@"title"];
    }else{
        return @"No title";
    }
}
@end

