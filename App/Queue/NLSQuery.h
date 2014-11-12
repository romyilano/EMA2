//
//  NLSQuery.h
//  App
//
//  Created by Amir on 11/7/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLSSQLAPI.h"
#import "NLSSQLCount.h"

@protocol NLSQueryDelegate;

@interface NLSQuery : NSOperation

@property (nonatomic, assign) id <NLSQueryDelegate> delegate;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSInvocation* invocation;
@property (readwrite, assign) NSInteger result;

- (void)main;
- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSQueryDelegate>)delegate;

@end

//Delegate
@protocol NLSQueryDelegate <NSObject>

- (void)queryDidFinish:(NLSQuery *)query;

@end