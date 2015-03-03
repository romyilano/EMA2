//
//  NLSTitleModel.m
//  App
//
//  Created by Amir on 7/24/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import "NLSTitleModel.h"

@implementation NLSTitleModel

@synthesize rowId = _rowId;
@synthesize cellId = _cellId;
@synthesize pmid = _pmid;
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
    self.pmid = -1;
    self.title = nil; // do your own initialization here
    self.year = nil;
    self.journal_abv = nil;
    self.descriptors = nil; //@[@{@"":@""}]
    self.failed = NO;
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

    if(self.rowId == -1 )
        //       || self.cellId == -1
        //       || self.pmid == -1
        //       || self.title == nil
        //       || self.descriptors == nil
        
        
    {
        NSLog(@"No Data");
        return NO;
    }else{
        return YES;
    }
    
}

- (BOOL)isFailed {
    return _failed;
}

- (void)addMeshArrayFromTm:(NLSTitleModel*)tm
{

    self.descriptors = [NSArray arrayWithArray:tm.descriptors];
    
}

@end
