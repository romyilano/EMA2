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

@property (strong, nonatomic) FMDatabaseQueue *queue;
@property (strong, nonatomic) FMDatabaseQueue *favesQ;
@property (nonatomic,retain) NSFileManager *fileMgr;
@property (nonatomic,retain) NSString *homeDir;

+ (id)sharedManager;

-(void)initDatabase;

-(NSInteger)getCountFromFavorites;
-(BOOL)insertIntoFavorites:(NSInteger)emaId;
-(BOOL)deleteFavorites;
-(BOOL)deleteFromFavorites:(NSInteger)emaId;
-(BOOL)checkForFavoriteId:(NSInteger)emaId;

-(NSString*)getTitleWhereId:(NSInteger)emaId;
-(NSString*)getPmidForId:(NSInteger)emaId;
-(NSString*)getMeshForId:(NSInteger)meshId;
-(NSArray *)getMeshDescriptorsForId:(NSInteger)emaId;

-(NLSTitleModel*)getTitleForId:(NSInteger)emaId;
-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val;
-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereTitleMatch:(NSString *)str;

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereMeshEquals:(NSInteger)meshId;
-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereMeshEquals:(NSInteger)meshId andTitleMatch:(NSString *)str;

-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereJournalEquals:(NSInteger)journalId;
-(NLSTitleModel*)getTitleAndIdForRow:(NSInteger)val whereJournalEquals:(NSInteger)val andTitleMatch:(NSString *)str;

-(NLSTitleModel*)getFavoriteForRow:(NSInteger)val;

-(NSInteger)getTitleCount;
-(NSInteger)getTitleCountWhereMeshEquals:(NSInteger)meshId;
-(NSInteger)getTitleCountWhereMeshEquals:(NSInteger)meshId andTitleMatch:(NSString *)str;
-(NSInteger)getTitleCountWhereTitleMatch:(NSString*)str;
-(NSInteger)getTitleCountWhereJournalEquals:(NSInteger)journalId;
-(NSInteger)getTitleCountWhereJournalEquals:(NSInteger)journalId andTitleMatch:(NSString*)str;

-(NSInteger)getCountFromDescriptorsWhereSectionLike:str;
-(NLSDescriptorModel*)getDescriptorForRow:(NSInteger)val whereSectionLike:(NSString *)str;

-(NSInteger)getCountFromJournalsWhereSectionLike:str;
-(NLSJournalModel*)getJournalTitleForRow:(NSInteger)val whereSectionLike:(NSString *)str;

-(NLSDetailModel*)getAbstractWithId:(NSInteger)val;

@end
