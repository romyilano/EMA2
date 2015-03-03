//
//  NLSTitleModel.h
//  App
//
//  Created by Amir on 7/24/14.
//  Copyright (c) 2014 Colleen's Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLSTitleModel : NSObject

@property (readwrite, assign) NSInteger rowId;
@property (readwrite, assign) NSInteger cellId;
@property (readwrite, assign) NSInteger pmid;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *journal_abv;
@property (strong, nonatomic) NSArray *descriptors;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSString *searchText;

@property (copy) NLSTitleModel* (^sqlQuery)(void);

@property (nonatomic, readonly) BOOL hasData; // Return YES if data is downloaded.
@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if TitleModel failed to be populated

- (id)initWithCellId:(NSInteger)cellId;
- (id)initWithCellId:(NSInteger)cellId andSearchBarText:(NSString*)str;
- (void)addMeshArrayFromTm:(NLSTitleModel*)tm;

@end
