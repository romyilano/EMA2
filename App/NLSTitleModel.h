//
//  NLSTitleModel.h
//  App
//
//  Created by Amir on 7/24/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLSTitleModel : NSObject

@property (readwrite, assign) NSUInteger rowId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *journal_abv;
@property (strong, nonatomic) NSArray *descriptors;
@end
