//
//  NLSDetailQuery.h
//  App
//
//  Created by Amir Djavaherian on 11/17/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import "NLSQuery.h"
#import "NLSDetailModel.h"

@protocol NLSDetailQueryDelegate;

@interface NLSDetailQuery : NLSQuery

@property (nonatomic, assign) id <NLSDetailQueryDelegate> dmDelegate;

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSDetailQueryDelegate>)delegate;

@end

//Delegate
@protocol NLSDetailQueryDelegate <NSObject>

- (void)detailQueryDidFinish:(NLSDetailModel *)dm;

@end