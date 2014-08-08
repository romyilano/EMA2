//
//  NLSJournalModel.h
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLSJournalModel : NSObject

@property (readwrite, assign) NSUInteger rowId;
@property (strong, nonatomic) NSString *journal_title;

@end

