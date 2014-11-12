//
//  NLSSQLCount.m
//  App
//
//  Created by Amir on 11/7/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import "NLSSQLCount.h"

@implementation NLSSQLCount

@synthesize result = _result;
@synthesize failed = _failed;
@synthesize searchStr = _searchStr;
@synthesize data = _data;

- (id) init
{
    self.result = 0;
    self.searchStr = nil;
    return self;
}

- (id)initWithSearchBarText:(NSString*)str {
    
    if (self = [super init]) {
        self.searchStr = str;
    }
    return self;
}

- (BOOL)isSearchStr {
    if(!self.searchStr){
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
