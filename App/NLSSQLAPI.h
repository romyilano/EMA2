//
//  NLSSQLAPI.h
//  App
//
//  Created by Amir on 7/23/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FMDB.h"

@interface NLSSQLAPI : NSObject

@property (strong, nonatomic) NSMutableArray *tableArray;
@property (strong, nonatomic) FMDatabase *db;

-(void)initDatabase;
-(int)getTitleCount;
-(NSArray*)getTitlesToLimit:(int)limit;
-(NSString*)getTitleForId:(NSInteger)val;
-(NSDictionary *)getTitleAndIdForRow:(NSInteger)val;

@end
