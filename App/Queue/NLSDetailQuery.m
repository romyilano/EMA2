//
//  NLSDetailQuery.m
//  App
//
//  Created by Amir Djavaherian on 11/17/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import "NLSDetailQuery.h"

@implementation NLSDetailQuery

@synthesize dmDelegate = _dmDelegate;

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSDetailQueryDelegate>)delegate
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), invocation);
    if (self = [super init]) {
        self.invocation = invocation;
        self.dmDelegate = delegate;
    }
    return self;
}


- (void)main {
    
    NSLog(@"NLSDetailQuery %@", NSStringFromSelector(_cmd));
    
    if (self.isCancelled){
        return;
    }else{
        void *tempDm;
        [self.invocation invoke];
        [self.invocation getReturnValue:&tempDm];
        NLSDetailModel *dm = (__bridge NLSDetailModel *)tempDm;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.dmDelegate detailQueryDidFinish:dm];
        
        });
        
    }
    
}

@end
