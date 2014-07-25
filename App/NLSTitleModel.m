//
//  NLSTitleModel.m
//  App
//
//  Created by Amir on 7/24/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSTitleModel.h"

@implementation NLSTitleModel

@synthesize titleArray = _titleArray;
@synthesize sql = _sql;

-(NLSTitleModel*)init
{

    NSLog(@"init NLSTitleModel");
    NLSSQLAPI *sqlapi = [[NLSSQLAPI alloc]  init];
    self.sql = sqlapi;
    [self.sql initDatabase];
    
    return self;
}

-(NSArray*)getTitleWithId:(NSUInteger)id
{
    NSArray *title = [[NSArray alloc] init];    
    return title;
}

@end
