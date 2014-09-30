//
//  SQLQuery.m
//  App
//
//  Created by 4m1r on 9/23/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import "SQLQuery.h"


// 1: Declare a private interface, so you can change the attributes of instance variables to read-write.
@interface SQLQuery ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) NLSTitleModel *titleModel;
@end


@implementation SQLQuery
@synthesize delegate = _delegate;
@synthesize indexPathInTableView = _indexPathInTableView;
@synthesize titleModel = _titleModel;
@synthesize sql = _sql;

- (NLSSQLAPI *)sql{
    if(!_sql){
        _sql = [NLSSQLAPI sharedManager];
    }
    return _sql;
}


#pragma mark -
#pragma mark - Life Cycle

- (id)initWithTitleModel:(NLSTitleModel *)tm atIndexPath:(NSIndexPath *)indexPath delegate:(id<SQLQueryDelegate>)theDelegate{
    
    if (self = [super init]) {
        // 2: Set the properties.
        self.delegate = theDelegate;
        self.indexPathInTableView = indexPath;
        self.titleModel = tm;
    }
    return self;
}

#pragma mark -
#pragma mark - SQL Query
#pragma GCC diagnostic ignored "-Wselector"
// 3: Regularly check for isCancelled, to make sure the operation terminates as soon as possible.
- (void)main {
    
    // 4: Apple recommends using @autoreleasepool block instead of alloc and init NSAutoreleasePool, because blocks are more efficient. You might use NSAuoreleasePool instead and that would be fine.
    @autoreleasepool {
        

        if (self.isCancelled)
            return;
        
        NSInteger cell = self.titleModel.cellId;
        NSString *searchText = self.titleModel.searchText;
        
        if (self.isCancelled) {
            cell = -1;
            return;
        }
        
        if (cell >= 0) {

            NSLog(@"setting tm for row %ld", (long)cell);
            
            NLSTitleModel *tm = self.titleModel.sqlQuery();

            self.titleModel = tm;
        }
        else {
            self.titleModel.failed = YES;
        }
        
        cell = -1;
        
        if (self.isCancelled)
            return;

        // 5: Cast the operation to NSObject, and notify the caller on the main thread.
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(sqlQueryDidFinish:) withObject:self waitUntilDone:NO];
        
    }
}

@end


