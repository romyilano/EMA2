//
//  NLSTitleModel.m
//  App
//
//  Created by Amir on 7/24/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSTitleModel.h"

@implementation NLSTitleModel

@synthesize rowId = _rowId;
@synthesize title = _title;
@synthesize year = _year;
@synthesize journal_abv = _journal_abv;
@synthesize descriptors = _descriptors;

- (id) init
{
    self.title = @"Title"; // do your own initialisation here
    self.year = @"Year";
    self.journal_abv = @"Journal Abv";
    return self;
}

@end
