//
//  NLSAppDelegate.h
//
//  Created by 4m1r on 8/12/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLSSQLAPI.h"
#include "EMAConstants.h"

@interface NLSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *controller;
@property (nonatomic,retain) NSFileManager *fileMgr;
@property (nonatomic,retain) NSString *homeDir;
@property (strong, nonatomic) NLSSQLAPI *sql;

@end
