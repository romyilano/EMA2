//
//  NLSPendingOperations.m
//  ClassicPhotos
//
//  Created by Amir Djavaherian on 11/7/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSPendingOperations.h"

@implementation NLSPendingOperations
@synthesize queriesInProgress = _queriesInProgress;
@synthesize searchQueriesInProgress = _searchQueriesInProgress;
@synthesize countsInProgress = _countsInProgress;
@synthesize queryQueue = _queryQueue;

- (NSMutableArray *)queriesInProgress {
    if (!_queriesInProgress) {
        _queriesInProgress = [[NSMutableArray alloc] init];
    }
    return _queriesInProgress;
}

- (NSMutableDictionary *)searchQueriesInProgress {
    if (!_searchQueriesInProgress) {
        _searchQueriesInProgress = [[NSMutableDictionary alloc] init];
    }
    return _searchQueriesInProgress;
}

- (NSMutableArray *)countsInProgress{
    if(!_countsInProgress){
        _countsInProgress = [[NSMutableArray alloc] init];
    }
    return _countsInProgress;
}

- (NSOperationQueue *)queryQueue {
    if (!_queryQueue) {
        _queryQueue = [[NSOperationQueue alloc] init];
        _queryQueue.name = @"Query Queue";
        _queryQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _queryQueue;
}


@end
