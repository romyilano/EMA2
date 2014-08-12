//
//  NLSAppDelegate.h
//
//  Created by Patrick Piemonte on 1/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) NSFileManager *fileMgr;
@property (nonatomic,retain) NSString *homeDir;
@property (nonatomic,retain) NSString *title;

@end
