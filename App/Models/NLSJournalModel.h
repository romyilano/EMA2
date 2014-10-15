//
//  NLSJournalModel.h
//  App
//
//  Created by Amir on 8/7/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLSJournalModel : NSObject

@property (readwrite, assign) NSInteger rowId;
@property (strong, nonatomic) NSString *journal_title;
@property (strong, nonatomic) NSString *issn;

@end

