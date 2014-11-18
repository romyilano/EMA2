//
//  NLSTMQuery.h
//  App
//
//  Created by Amir on 11/17/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import "NLSQuery.h"
#import "NLSTitleModel.h"

@protocol NLSTMQueryDelegate;

@interface NLSTMQuery : NLSQuery

@property (nonatomic, assign) id <NLSTMQueryDelegate> tmDelegate;
@property (strong, nonatomic) NLSTitleModel *titleModel;
@property (nonatomic, strong) NSIndexPath *indexPathInTableView;

- (id)initWithInvocation:(NSInvocation *)invocation atIndexPath:(NSIndexPath *)indexPath andDelegate:(id<NLSTMQueryDelegate>)delegate;

@end

//Delegate
@protocol NLSTMQueryDelegate <NSObject>

- (void)sqlQueryDidFinish:(NLSTMQuery *)query;

@end