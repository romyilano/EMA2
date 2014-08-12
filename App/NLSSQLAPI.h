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
@property (nonatomic,retain) NSFileManager *fileMgr;
@property (nonatomic,retain) NSString *homeDir;

+ (id)sharedManager;

-(void)initDatabase;
-(int)getTitleCount;

-(NSUInteger)getTitleCountWhereMeshEquals:(NSUInteger)meshId;
-(NSUInteger)getTitleCountWhereTitleContains:(NSString*)str;
-(NSUInteger)getTitleCountWhereJournalEquals:(NSUInteger)journalId;
-(NSUInteger)getCountFromTable:(NSString*)table whereCol:(NSString*)col like:(NSString*)str;

-(NSArray*)getTitlesToLimit:(int)limit;
-(NSString*)getTitleForId:(NSInteger)val;

-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereTitleMatch:(NSString *)str;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereMeshEquals:(NSUInteger)meshId;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val whereJournalEquals:(NSUInteger)journalId;

-(NLSDescriptorModel*)getDescriptorForRow:(NSUInteger)val whereSectionLike:(NSString *)str;
-(NLSJournalModel*)getJournalTitleForRow:(NSUInteger)val whereSectionLike:(NSString *)str;
-(NLSDetailModel*)getAbstractWithId:(NSUInteger)val;


@end
