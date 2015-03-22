//
//  NLSJournalQuery.m
//  App
//
//  Created by Amir Djavaherian on 11/17/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import "NLSJournalQuery.h"

@implementation NLSJournalQuery

@synthesize tmDelegate = _tmDelegate;
@synthesize titleModel = _titleModel;

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSJournalQueryDelegate>)delegate
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), invocation);
    if (self = [super init]) {
        self.invocation = invocation;
        self.tmDelegate = delegate;
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
    
    [(NSObject*)self.tmDelegate performSelectorOnMainThread:@selector(journalQueryDidFinish:) withObject:self waitUntilDone:NO];
    
    
}

@end
