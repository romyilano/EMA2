//
//  NLSDetailViewController.h
//  App
//
//  Created by Amir on 7/25/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"
#import "NLSButton.h"

@interface NLSDetailViewController : UIViewController

@property (readwrite, assign) NSUInteger abstractId;
@property (strong, nonatomic) NLSSQLAPI *sql;
@property (strong, nonatomic) NLSButton *button;
@property (strong, nonatomic) UIWindow *window;

@end
