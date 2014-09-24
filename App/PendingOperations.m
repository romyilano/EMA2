//
//  PendingOperations.m
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations
@synthesize queriesInProgress = _queriesInProgress;
@synthesize queryQueue = _queryQueue;

- (NSMutableDictionary *)queriesInProgress {
    if (!_queriesInProgress) {
        _queriesInProgress = [[NSMutableDictionary alloc] init];
    }
    return _queriesInProgress;
}

- (NSOperationQueue *)queryQueue {
    if (!_queryQueue) {
        _queryQueue = [[NSOperationQueue alloc] init];
        _queryQueue.name = @"Query Queue";
        _queryQueue.maxConcurrentOperationCount = 1;
    }
    return _queryQueue;
}


@end
