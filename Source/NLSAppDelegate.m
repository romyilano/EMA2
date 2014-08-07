//
//  NLSAppDelegate.m
//
//  Created by Patrick Piemonte on 1/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NLSAppDelegate.h"
#import "NLSViewController.h"
#import "NLSDescriptorViewController.h"
#import "PBJActivityIndicator.h"
#import "FICImageCache.h"


@interface NLSAppDelegate ()
{
    UIWindow *_window;

}

@end

@implementation NLSAppDelegate

@synthesize window = _window;


#pragma mark - init


#pragma mark - App State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
// TODO: load the heirarchy in another place after login

    NLSViewController *viewController = [[NLSViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:viewController];
    nc.title = @"Titles";
    
    NLSDescriptorViewController *descriptorController = [[NLSDescriptorViewController alloc] init];
    UINavigationController *dc = [[UINavigationController alloc] initWithRootViewController:descriptorController];
    dc.title = @"Descriptors";
    
    NLSViewController *journalsController = [[NLSViewController alloc] init];
    UINavigationController *jc = [[UINavigationController alloc] initWithRootViewController:journalsController];
    dc.title = @"Journals";
    
    NLSViewController *favoritesController = [[NLSViewController alloc] init];
    UINavigationController *fc = [[UINavigationController alloc] initWithRootViewController:favoritesController];
    dc.title = @"Favorites";
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    NSArray* controllers = [NSArray arrayWithObjects:nc, dc, jc, fc, nil];
    tabBarController.viewControllers = controllers;
    
    UIImage *titlesImage = [UIImage imageNamed:@"Document-50.png"];
    UIImage *descriptorsImage = [UIImage imageNamed:@"Descriptors-50.png"];
    UIImage *journalsImage = [UIImage imageNamed:@"Journals-50.png"];
    UIImage *favoritesImage = [UIImage imageNamed:@"Favorites-50.png"];
    
    nc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Titles" image:titlesImage selectedImage:titlesImage];
    dc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"MeSH Descriptors" image:descriptorsImage selectedImage:descriptorsImage];
    jc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Journals" image:journalsImage selectedImage:journalsImage];
    fc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Favorites" image:favoritesImage selectedImage:favoritesImage];
    
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
    [[PBJActivityIndicator sharedActivityIndicator] setSuppressed:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[PBJActivityIndicator sharedActivityIndicator] setSuppressed:NO];
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
    [[FICImageCache sharedImageCache] reset];
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
