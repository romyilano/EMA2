//
//  NLSDescriptorArrayQuery.h
//  App
//
//  Created by Amir on 3/19/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSQuery.h"

@protocol NLSDescriptorArrayQueryDelegate;

@interface NLSDescriptorArrayQuery : NLSQuery

@property (nonatomic, assign) id <NLSDescriptorArrayQueryDelegate> tmDelegate;
@property (strong, nonatomic) NLSTitleModel *titleModel;

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSDescriptorArrayQueryDelegate>)delegate;

@end

//Delegate
@protocol NLSDescriptorArrayQueryDelegate <NSObject>

- (void)sqlQueryDidFinishForMeshArray:(NLSDescriptorArrayQuery *)query;

@end
