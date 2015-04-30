//
//  NLSQuery.m
//  App
//
//  Created by Amir Djavaherian on 11/7/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//
#pragma GCC diagnostic ignored "-Wselector"
#import "NLSTMArrayQuery.h"

@interface NLSTMArrayQuery ()
@end


@implementation NLSTMArrayQuery

@synthesize delegate = _delegate;
@synthesize sql = _sql;
@synthesize invocation = _invocation;

- (NLSSQLAPI *)sql{
    if(!_sql){
        _sql = [NLSSQLAPI sharedManager];
    }
    return _sql;
}

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSTMArrayQueryDelegate>)delegate
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
        void *tmpResult;
        [self.invocation invoke];
        [self.invocation getReturnValue:&tmpResult];
        NSArray *result = (__bridge NSArray *)tmpResult;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate arrayQueryDidFinish:result];
            
        });
    }
    
    
}


@end
