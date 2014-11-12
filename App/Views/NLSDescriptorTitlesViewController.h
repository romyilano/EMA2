//
//  NLSDescriptorTitlesViewController.h
//  App
//
//  Created by Amir Djavaherian on 8/7/14.
//  Copyright (c) 2014 Colleen's. All rights reserved.
//

#import "NLSTitleViewController.h"
#import "NLSTableViewCell.h"
#import "NLSTitleModel.h"

@interface NLSDescriptorTitlesViewController : NLSTitleViewController

@property (readwrite, assign) NSUInteger section;
@property (strong, nonatomic) NSArray *letters;
@property (strong, nonatomic) NSString *descriptor;
@property (readwrite, assign) NSInteger meshId;

@end
