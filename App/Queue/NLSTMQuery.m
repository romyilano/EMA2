//
//  NLSTMQuery.m
//  App
//
//  Created by Amir on 11/17/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import "NLSTMQuery.h"

@implementation NLSTMQuery

@synthesize tmDelegate = _tmDelegate;
@synthesize titleModel = _titleModel;
@synthesize indexPathInTableView = _indexPathInTableView;

- (id)initWithInvocation:(NSInvocation *)invocation atIndexPath:(NSIndexPath *)indexPath andDelegate:(id<NLSTMQueryDelegate>)tmDelegate
{
    if (self = [super init]) {
        self.invocation = invocation;
        self.indexPathInTableView = indexPath;
        self.tmDelegate = tmDelegate;
        self.titleModel = nil;
    }
    return self;
}


- (void)main {
    
    if (self.isCancelled){
        return;
    }else{
        NLSTitleModel *tm = [[NLSTitleModel alloc] init];
        [self.invocation invoke];
        [self.invocation getReturnValue:&tm];
        self.titleModel = tm;
    }
    
    [(NSObject*)self.tmDelegate performSelectorOnMainThread:@selector(sqlQueryDidFinish:) withObject:self waitUntilDone:NO];
    
}

@end
