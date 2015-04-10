//
//  NLSDescriptorArrayQuery.m
//  App
//
//  Created by Amir on 3/19/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSDescriptorArrayQuery.h"

@implementation NLSDescriptorArrayQuery

@synthesize tmDelegate = _tmDelegate;

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSDescriptorArrayQueryDelegate>)delegate
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), invocation);
    if (self = [super init]) {
        self.invocation = invocation;
        self.tmDelegate = delegate;
    }
    return self;
}


- (void)main {
    NSLog(@"NLSDescriptorArrayQuery %@", NSStringFromSelector(_cmd));
    if (self.isCancelled){
        return;

    }else{
        void *tempTm;
        [self.invocation invoke];
        [self.invocation getReturnValue:&tempTm];
        NLSTitleModel *tm = (__bridge NLSTitleModel *)tempTm;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tmDelegate sqlQueryDidFinishForMeshArray:tm];
        });
        
    }
    
}

@end
