//
//  NLSTableViewCell.h
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSTitleModel.h"

@interface NLSTableViewCell : UITableViewCell

@property (readwrite, assign) NSInteger rowId;
@property (strong, nonatomic) NSString *name;

@end
