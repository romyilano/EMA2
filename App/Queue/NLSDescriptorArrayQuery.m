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
@synthesize titleModel = _titleModel;

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSDescriptorArrayQueryDelegate>)delegate
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
    
    [(NSObject*)self.tmDelegate performSelectorOnMainThread:@selector(sqlQueryDidFinishForMeshArray:) withObject:self waitUntilDone:NO];
    
    
}

@end
