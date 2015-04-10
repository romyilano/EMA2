//
//  NLSTMQuery.h
//  App
//
//  Created by Amir Djavaherian on 11/17/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSQuery.h"
#import "NLSTitleModel.h"

@protocol NLSTMQueryDelegate;

@interface NLSTMQuery : NLSQuery

@property (nonatomic, assign) id <NLSTMQueryDelegate> tmDelegate;

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSTMQueryDelegate>)delegate;

@end

//Delegate
@protocol NLSTMQueryDelegate <NSObject>

- (void)sqlQueryDidFinish:(NLSTitleModel *)tm;

@end