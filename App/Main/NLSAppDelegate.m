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
#import "NLSAboutViewController.h"
#import "NLSDetailViewController.h"
#import "EDColor.h"
#import "CRGradientNavigationBar.h"
#import "PBJActivityIndicator.h"

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
    self.sql = [NLSSQLAPI sharedManager];

}


#pragma mark - App State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self checkAndCreateDatabase];

    NLSTitleViewController *titlesController = [[NLSTitleViewController alloc] init];
    UINavigationController *tnc = [self styledNavigationController];
    [tnc setViewControllers:@[titlesController]];
    
    NLSDescriptorViewController *descriptorController = [[NLSDescriptorViewController alloc] init];
    UINavigationController *dnc = [self styledNavigationController];
    [dnc setViewControllers:@[descriptorController]];
    
    NLSJournalViewController *journalsController = [[NLSJournalViewController alloc] init];
    UINavigationController *jnc = [self styledNavigationController];
    [jnc setViewControllers:@[journalsController]];
    
    NLSFavoritesViewController *favoritesController = [[NLSFavoritesViewController alloc] init];
    UINavigationController *fnc = [self styledNavigationController];
    [fnc setViewControllers:@[favoritesController]];
    
    NLSAboutViewController *aboutController = [[NLSAboutViewController alloc ] init];
    UINavigationController *anc = [self styledNavigationController];
    [anc setViewControllers:@[aboutController]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:favoritesColor]];
    
    NSArray* controllers = [NSArray arrayWithObjects:tnc, dnc, jnc, fnc, anc, nil];
    tabBarController.viewControllers = controllers;
    
    UIImage *titlesImage = [UIImage imageNamed:@"Document-50.png"];
    UIImage *titlesImageSelected = [UIImage imageNamed:@"Document-selected-50.png"];
    UIImage *descriptorsImage = [UIImage imageNamed:@"Descriptors-50.png"];
    UIImage *descriptorsImageSelected = [UIImage imageNamed:@"Descriptors-selected-50.png"];
    UIImage *journalsImage = [UIImage imageNamed:@"Journals-50.png"];
    UIImage *journalsImageSelected = [UIImage imageNamed:@"Journals-selected-50.png"];
    UIImage *favoritesImage = [UIImage imageNamed:@"Favorites-50.png"];
    UIImage *favoritesImageSelected = [UIImage imageNamed:@"Favorites-selected-50.png"];
    UIImage *aboutImage = [UIImage imageNamed:@"About-50.png"];
    UIImage *aboutImageSelected = [UIImage imageNamed:@"About-selected-50.png"];
    
    tnc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Titles" image:titlesImage selectedImage:titlesImage];
    dnc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Descriptors" image:descriptorsImage selectedImage:descriptorsImage];
    jnc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Journals" image:journalsImage selectedImage:journalsImage];
    fnc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Favorites" image:favoritesImage selectedImage:favoritesImage];
    anc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"About" image:aboutImage selectedImage:aboutImage];
    
    [tnc.tabBarItem setSelectedImage: titlesImageSelected];
    [dnc.tabBarItem setSelectedImage: descriptorsImageSelected];
    [jnc.tabBarItem setSelectedImage: journalsImageSelected];
    [fnc.tabBarItem setSelectedImage: favoritesImageSelected];
    [anc.tabBarItem setSelectedImage: aboutImageSelected];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
    self.window.rootViewController = tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UINavigationController*)styledNavigationController
{

    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];

    UIColor *firstColor = [UIColor colorWithHexString:@"#55EFCB"];
    UIColor *secondColor = [UIColor colorWithHexString:@"#5BCAFF"];
    
    NSArray *colors = [NSArray arrayWithObjects:firstColor, secondColor, nil];
    
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    
    navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithHexString:@"#FFFFFF"], NSForegroundColorAttributeName,
                                                              [UIFont fontWithName:@"AvenirNext-Medium" size:20.0], NSFontAttributeName, nil];

    navigationController.navigationBar.tintColor = [UIColor  whiteColor];
    navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [[navigationController navigationBar] setTranslucent:YES];
//    [[navigationController navigationBar] setShadowImage:[UIImage new]];
    
    return navigationController;
    
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