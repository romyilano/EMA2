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
#import "NLSDetailModel.h"

@interface NLSSQLAPI : NSObject

@property (strong, nonatomic) NSMutableArray *tableArray;
@property (strong, nonatomic) FMDatabase *db;

-(void)initDatabase;
-(int)getTitleCount;
-(NSArray*)getTitlesToLimit:(int)limit;
-(NSString*)getTitleForId:(NSInteger)val;
-(NLSTitleModel*)getTitleAndIdForRow:(NSUInteger)val;
-(NLSDescriptorModel*)getDescriptorForRow:(NSUInteger)val whereSectionLike:(NSString *)str;
-(NLSDetailModel*)getAbstractWithId:(NSUInteger)val;
-(NSUInteger)getCountFromTable:(NSString*)table whereCol:(NSString*)col like:(NSString*)str;
@end
