//
//  NLSTMArrayQuery.h
//  Colleen's EMA
//
//  Created by Amir Djavaherian on 11/7/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLSSQLAPI.h"
#import "NLSSQLCount.h"

@protocol NLSTMArrayQueryDelegate;

@interface NLSTMArrayQuery : NSOperation

@property (nonatomic, assign) id <NLSTMArrayQueryDelegate> delegate;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSInvocation *invocation;

- (void)main;
- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSTMArrayQueryDelegate>)delegate;

@end

//Delegate
@protocol NLSTMArrayQueryDelegate <NSObject>

- (void)arrayQueryDidFinish:(NSArray *)array;

@end