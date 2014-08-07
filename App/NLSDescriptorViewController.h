//
//  NLSDescriptorViewController.h
//  App
//
//  Created by Amir on 8/6/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"

@interface NLSDescriptorViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NSArray *letters;

@end
