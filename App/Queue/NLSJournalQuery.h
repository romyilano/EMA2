//
//  NLSJournalQuery.h
//  App
//
//  Created by Amir Djavaherian on 11/17/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSQuery.h"
#import "NLSTitleModel.h"

@protocol NLSJournalQueryDelegate;

@interface NLSJournalQuery : NLSQuery

@property (nonatomic, assign) id <NLSJournalQueryDelegate> tmDelegate;

- (id)initWithInvocation:(NSInvocation *)invocation andDelegate:(id<NLSJournalQueryDelegate>)delegate;

@end

//Delegate
@protocol NLSJournalQueryDelegate <NSObject>

- (void)journalQueryDidFinish:(NLSTitleModel *)tm;

@end