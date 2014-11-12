//
//  NLSQuery.m
//  App
//
//  Created by Amir on 11/7/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//
#pragma GCC diagnostic ignored "-Wselector"
#import "NLSQuery.h"

@interface NLSQuery ()
@property (nonatomic, readwrite, strong) NLSSQLCount *sqlCount;
@end


@implementation NLSQuery

@synthesize delegate = _delegate;
@synthesize sql = _sql;
@synthesize sqlCount = _sqlCount;
@synthesize result = _result;
@synthesize invocation = _invocation;

- (NLSSQLAPI *)sql{
    if(!_sql){
        _sql = [NLSSQLAPI sharedManager];
    }
    return _sql;
}

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSQueryDelegate>)delegate
{
    if (self = [super init]) {
        self.invocation = invocation;
        self.delegate = delegate;
        self.result = 0;
    }
    return self;
}

- (void)main {
    
    if (self.isCancelled){
        return;
    }else{
        NSInteger *result = nil;
        [self.invocation invoke];
        [self.invocation getReturnValue:&result];
        self.result = result;
    }
    
    [(NSObject*)self.delegate performSelectorOnMainThread:@selector(queryDidFinish:) withObject:self waitUntilDone:NO];
    
}


@end
