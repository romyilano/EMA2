//
//  PendingOperations.h
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *queriesInProgress;
@property (nonatomic, strong) NSOperationQueue *queryQueue;

@end
