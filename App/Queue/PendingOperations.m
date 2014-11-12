//
//  PendingOperations.m
//  ClassicPhotos
//
//  Created by Amir Djavaherian on 11/7/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations
@synthesize queriesInProgress = _queriesInProgress;
@synthesize countsInProgress = _countsInProgress;
@synthesize queryQueue = _queryQueue;

- (NSMutableDictionary *)queriesInProgress {
    if (!_queriesInProgress) {
        _queriesInProgress = [[NSMutableDictionary alloc] init];
    }
    return _queriesInProgress;
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
