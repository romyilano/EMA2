//
//  NLSSQLCount.h
//  App
//
//  Created by Amir on 11/7/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLSSQLCount : NSObject

@property (readwrite, assign) NSInteger result;
@property (strong, nonatomic) NSString *searchStr;
@property (strong, nonatomic) NSData *data;


@property (copy) NLSSQLCount* (^sqlQuery)(void);

@property (nonatomic, readonly) BOOL hasData; // Return YES if data is downloaded.
@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if TitleModel failed to be populated

- (id)init;
- (id)initWithSearchBarText:(NSString*)str;

@end
