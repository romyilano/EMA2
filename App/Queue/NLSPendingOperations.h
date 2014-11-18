//
//  NLSPendingOperations.h
//
//  Created by Amir Djavaherian on 11/7/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.

//

#import <Foundation/Foundation.h>

@interface NLSPendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *queriesInProgress;
@property (nonatomic, strong) NSMutableDictionary *searchQueriesInProgress;
@property (nonatomic, strong) NSMutableArray *countsInProgress;
@property (nonatomic, strong) NSOperationQueue *queryQueue;

@end
