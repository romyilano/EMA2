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
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self = [super init]) {
        self.invocation = invocation;
        self.indexPathInTableView = indexPath;
        self.tmDelegate = tmDelegate;
        self.titleModel = [[NLSTitleModel alloc] init];
    }
    return self;
}


- (void)main {
    NSLog(@"NLSTMQuery %@", NSStringFromSelector(_cmd));
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
