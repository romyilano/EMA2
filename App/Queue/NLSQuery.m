//
//  NLSQuery.m
//  App
//
//  Created by Amir Djavaherian on 11/7/14.
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
    }
    return self;
}

- (void)main {
    
    if (self.isCancelled){
        return;
    }else{
        NSInteger *tmpResult = nil;
        [self.invocation invoke];
        [self.invocation getReturnValue:&tmpResult];
        NSInteger *result = tmpResult;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate queryDidFinish:result];
            
        });
    }
    
    
}


@end
