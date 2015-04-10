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

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSJournalQueryDelegate>)delegate
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), invocation);
    if (self = [super init]) {
        self.invocation = invocation;
        self.tmDelegate = delegate;
    }
    return self;
}


- (void)main {
    
    
    NSLog(@"NLSJournalQuery %@", NSStringFromSelector(_cmd));
    if (self.isCancelled){
        return;
    }else{
        void *tempTm;
        [self.invocation invoke];
        [self.invocation getReturnValue:&tempTm];
        NLSTitleModel *tm = (__bridge NLSTitleModel *)tempTm;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tmDelegate journalQueryDidFinish:tm];
            
        });
    }

    
}

@end
