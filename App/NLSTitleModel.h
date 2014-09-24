//
//  NLSTitleModel.h
//  App
//
//  Created by Amir on 7/24/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NLSTitleModel : NSObject

@property (readwrite, assign) NSInteger rowId;
@property (readwrite, assign) NSInteger cellId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *journal_abv;
@property (strong, nonatomic) NSArray *descriptors;
@property (strong, nonatomic) NSData *data;


@property (nonatomic, readonly) BOOL hasData; // Return YES if data is downloaded.
@property (nonatomic, getter = isAttributed) BOOL attributed; // Return YES if image is attributed
@property (nonatomic, getter = isFailed) BOOL failed; // Return Yes if image failed to be downloaded

- (id)initWithCellId:(NSInteger)cellId;

@end
