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
#import "NLSTitleModel.h"
#import "NLSDescriptorModel.h"
#import "NLSJournalModel.h"
#import "NLSDetailModel.h"

@interface NLSSQLAPI : NSObject

@property (strong, nonatomic) NSMutableArray *tableArray;
@property (strong, nonatomic) FMDatabase *db;
@property (strong, nonatomic) FMDatabase *favesDb;
@property (nonatomic,retain) NSFileManager *fileMgr;
@property (nonatomic,retain) NSString *homeDir;

+ (id)sharedManager;

-(void)initDatabase;
-(void)createTitles;
-(void)createDescriptors;

-(NSUInteger)getCountFromFavorites;
-(BOOL)insertIntoFavorites:(NSUInteger)emaId;
-(BOOL)deleteFavorites;
-(BOOL)deleteFromFavorites:(NSUInteger)emaId;
-(BOOL)checkForFavoriteId:(NSUInteger)emaId;

-(NSArray*)getTitlesToLimit:(int)limit;
-(NSString*)getTitleForId:(NSUInteger)val;
-(NSString*)getTitleWhereId:(NSUInteger)emaId;
-(NSString*)getPmidForId:(NSUInteger)emaId;
-(NSArray *)getMeshDescriptorsForId:(NSUInteger)emaId;

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereTitleMatch:(NSString *)str;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereMeshEquals:(NSUInteger)meshId;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereMeshEquals:(NSUInteger)meshId andTitleLike:(NSString *)str;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereJournalEquals:(NSUInteger)journalId;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereJournalEquals:(NSUInteger)val andTitleLike:(NSString *)str;
-(NLSTitleModel*)getFavoriteForRow:(NSUInteger)val;


-(NSUInteger)getCountFromTable:(NSString*)table;
-(NSUInteger)getCountFromTable:(NSString*)table whereCol:(NSString*)col like:(NSString*)str;

-(int)getTitleCount;
-(NSUInteger)getTitleCountWhereMeshEquals:(NSUInteger)meshId;
-(NSUInteger)getTitleCountWhereMeshEquals:(NSUInteger)meshId andTitleMatch:(NSString *)str;
-(NSUInteger)getTitleCountWhereTitleContains:(NSString*)str;
-(NSUInteger)getTitleCountWhereJournalEquals:(NSUInteger)journalId;
-(NSUInteger)getTitleCountWhereJournalEquals:(NSUInteger)journalId andTitleLike:(NSString*)str;

-(NLSDescriptorModel*)getDescriptorForRow:(NSUInteger)val whereSectionLike:(NSString *)str;

-(NLSJournalModel*)getJournalTitleForRow:(NSUInteger)val whereSectionLike:(NSString *)str;

-(NLSDetailModel*)getAbstractWithId:(NSUInteger)val;

-(NLSTitleModel*)get:(NSString *)cols from:(NSString *)table forRow:(NSUInteger)val;
-(NLSTitleModel*)get:(NSString *)cols from:(NSString *)table where:(NSString*)w like:(NSString*)l forRow:(NSUInteger)val;


@end
