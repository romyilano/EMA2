//
//  NLSQuery.h
//  Colleen's EMA
//
//  Created by Amir Djavaherian on 11/7/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLSSQLAPI.h"
#import "NLSSQLCount.h"

@protocol NLSQueryDelegate;

@interface NLSQuery : NSOperation

@property (nonatomic, assign) id <NLSQueryDelegate> delegate;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSInvocation *invocation;

- (void)main;
- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSQueryDelegate>)delegate;

@end

//Delegate
@protocol NLSQueryDelegate <NSObject>

- (void)queryDidFinish:(NSInteger *)result;

@end