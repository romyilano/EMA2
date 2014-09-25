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
@synthesize cellId = _cellId;
@synthesize title = _title;
@synthesize year = _year;
@synthesize journal_abv = _journal_abv;
@synthesize descriptors = _descriptors;
@synthesize failed = _failed;
@synthesize data = _data;
@synthesize searchText = _searchText;

- (id) init
{
    self.rowId = -1;
    self.cellId = -1;
    self.title = @"Title"; // do your own initialisation here
    self.year = @"Year";
    self.journal_abv = @"Journal Abv";
    self.descriptors = @[@{@"":@""}];
    self.data = nil;
    self.searchText = nil;
    return self;
}

- (id)initWithCellId:(NSInteger)cellId{
    
    if (self = [super init]) {
        self.cellId = cellId;
    }
    return self;
}

- (id)initWithCellId:(NSInteger)cellId andSearchBarText:(NSString*)str {

    if (self = [super init]) {
        self.cellId = cellId;
        self.searchText = str;
    }
    return self;
}

- (BOOL)isSearchText {
    if(!self.searchText){
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)hasData {
    if(!self.data){
        return NO;
    }else{
        return YES;
    }    
}

- (BOOL)isFailed {
    return _failed;
}

@end
