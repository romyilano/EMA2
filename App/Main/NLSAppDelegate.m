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
#import "NLSFeedViewController.h"
#import "NLSDetailViewController.h"
#import "EDColor.h"
#import "CRGradientNavigationBar.h"
#import "NLSUIKitExtras.h"
#import "NLSSearchViewController.h"


@implementation NLSAppDelegate

@synthesize window = _window;
@synthesize fileMgr = _fileMgr;
@synthesize homeDir = _homeDir;
@synthesize sql = _sql;
@synthesize controller = _controller;

#pragma mark - init

-(NSString *)GetDocumentDirectory{
    self.fileMgr = [NSFileManager defaultManager];
    self.homeDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    return self.homeDir;
}

-(void) checkAndCreateDatabase{

    self.sql = [NLSSQLAPI sharedManager];

}


#pragma mark - App State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //setup user default
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultUserDefaults" ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];

    
    //setup databases
    [self checkAndCreateDatabase];
    
    //setup global styles
    [[UINavigationBar appearance] setShadowImage:[UIImage fillImgOfSize:CGSizeMake(1,1) withColor:[UIColor colorWithHexString:searchGreen]]];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                             [UIColor whiteColor],NSForegroundColorAttributeName,
                             [UIFont fontWithName:@"Helvetica Neue" size:16], NSFontAttributeName,
                             nil] forState:UIControlStateNormal];
    
    
    [[UISearchBar appearance] setBackgroundImage:[UIImage fillImgOfSize:CGSizeMake(1,1) withColor:[UIColor colorWithHexString:searchGreen]]];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithHexString:favoritesColor]];

    //setup view controllers
    NLSTitleViewController *titlesController = [[NLSTitleViewController alloc] init];
    UINavigationController *tnc = [UINavigationController initStyled];
    [tnc setViewControllers:@[titlesController]];
    
    NLSDescriptorViewController *descriptorController = [[NLSDescriptorViewController alloc] init];
    UINavigationController *dnc = [UINavigationController initStyled];
    [dnc setViewControllers:@[descriptorController]];
    
    NLSJournalViewController *journalsController = [[NLSJournalViewController alloc] init];
    UINavigationController *jnc = [UINavigationController initStyled];
    [jnc setViewControllers:@[journalsController]];
    
    NLSFavoritesViewController *favoritesController = [[NLSFavoritesViewController alloc] init];
    UINavigationController *fnc = [UINavigationController initStyled];
    [fnc setViewControllers:@[favoritesController]];
    
    NLSAboutViewController *aboutController = [[NLSAboutViewController alloc ] init];
    UINavigationController *anc = [UINavigationController initStyled];
    [anc setViewControllers:@[aboutController]];
    
    NLSFeedViewController *feedController = [[NLSFeedViewController alloc ] init];
    UINavigationController *feedNC = [UINavigationController initStyled];
    [feedNC setViewControllers:@[feedController]];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.tabBar.translucent = NO;
    
    NSArray* controllers = [NSArray arrayWithObjects:tnc, dnc, jnc, fnc, anc, feedNC, nil];
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
    feedNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Pod Cast" image:aboutImage selectedImage:aboutImage];
    
    [tnc.tabBarItem setSelectedImage: titlesImageSelected];
    [dnc.tabBarItem setSelectedImage: descriptorsImageSelected];
    [jnc.tabBarItem setSelectedImage: journalsImageSelected];
    [fnc.tabBarItem setSelectedImage: favoritesImageSelected];
    [anc.tabBarItem setSelectedImage: aboutImageSelected];
    [feedNC.tabBarItem setSelectedImage: aboutImageSelected];
    
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
