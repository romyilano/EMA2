//
//  NLSAppDelegate.m
//
//  Created by 4m1r on 8/12/14.
//  Copyright (c) 2014 4m1r. All rights reserved.
//

#import "NLSAppDelegate.h"
#import "NLSTitleViewController.h"
#import "NLSDescriptorViewController.h"
#import "NLSJournalViewController.h"
#import "NLSFavoritesViewController.h"


@interface NLSAppDelegate ()
{
    UIWindow *_window;

}

@end

@implementation NLSAppDelegate

@synthesize window = _window;
@synthesize fileMgr = _fileMgr;
@synthesize homeDir = _homeDir;
@synthesize sql = _sql;


#pragma mark - init
-(NSString *)GetDocumentDirectory{
    self.fileMgr = [NSFileManager defaultManager];
    self.homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return self.homeDir;
}

-(void) checkAndCreateDatabase{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *databasePath = [self.GetDocumentDirectory stringByAppendingPathComponent:@"ema.sqlite"];
    success = [fileManager fileExistsAtPath:databasePath];
    if(success) {
        NSLog(@"DB exists in writeable Docs dir");
    }
    else{
        NSLog(@"DB does not exist in writeable Docs dir, copying...");
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ema.sqlite"];
        [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    }

}


#pragma mark - App State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self checkAndCreateDatabase];
    NLSSQLAPI *sqlapi = [NLSSQLAPI sharedManager];
    self.sql = sqlapi;

    NLSTitleViewController *titlesController = [[NLSTitleViewController alloc] init];
    UINavigationController *tnc = [[UINavigationController alloc] initWithRootViewController:titlesController];
    
    NLSDescriptorViewController *descriptorController = [[NLSDescriptorViewController alloc] init];
    UINavigationController *dnc = [[UINavigationController alloc] initWithRootViewController:descriptorController];
    
    NLSJournalViewController *journalsController = [[NLSJournalViewController alloc] init];
    UINavigationController *jnc = [[UINavigationController alloc] initWithRootViewController:journalsController];
    
    NLSFavoritesViewController *favoritesController = [[NLSFavoritesViewController alloc] init];
    UINavigationController *fnc = [[UINavigationController alloc] initWithRootViewController:favoritesController];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NSArray* controllers = [NSArray arrayWithObjects:tnc, dnc, jnc, fnc, nil];
    tabBarController.viewControllers = controllers;
    
    UIImage *titlesImage = [UIImage imageNamed:@"Document-50.png"];
    UIImage *descriptorsImage = [UIImage imageNamed:@"Descriptors-50.png"];
    UIImage *journalsImage = [UIImage imageNamed:@"Journals-50.png"];
    UIImage *favoritesImage = [UIImage imageNamed:@"Favorites-50.png"];
    
    tnc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Titles" image:titlesImage selectedImage:titlesImage];
    dnc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"MeSH Descriptors" image:descriptorsImage selectedImage:descriptorsImage];
    jnc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Journals" image:journalsImage selectedImage:journalsImage];
    fnc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Favorites" image:favoritesImage selectedImage:favoritesImage];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    

    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    NSLog(@"applicationDidBecomeActive");
    [self.sql createTitles];
    [self.sql createDescriptors];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

#pragma mark - System Notifications

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{

}

#pragma mark - APNS

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
#if !TARGET_IPHONE_SIMULATOR
	NSLog(@"failed to get token, error: %@", error);
#endif
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
}

@end
