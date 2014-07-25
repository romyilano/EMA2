//
//  NLSTitleModel.h
//  App
//
//  Created by Amir on 7/24/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLSSQLAPI.h"

@interface NLSTitleModel : NSObject

-(NSArray*)getTitleWithId:(NSUInteger)id;

@property (strong, nonatomic) NSMutableArray *titleArray;
@property (weak, nonatomic) NLSSQLAPI *sql;

@end
