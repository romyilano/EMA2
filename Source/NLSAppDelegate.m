//
//  NLSAppDelegate.m
//
//  Created by Patrick Piemonte on 1/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NLSAppDelegate.h"
#import "NLSLoginViewController.h"

#import "PBJActivityIndicator.h"
#import "FacebookSDK.h"
#import "FICImageCache.h"

@interface NLSAppDelegate ()
{
    UIWindow *_window;
}

@end

@implementation NLSAppDelegate

@synthesize window = _window;

#pragma mark - init

#pragma mark - Launch URL

//- (void)_handleLaunchFileURL:(NSURL *)launchFileURL;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return wasHandled;
}

#pragma mark - App State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
// TODO: load the heirarchy in another place after login
//    UIViewController *rootViewController = [[UIViewController alloc] init];
//    UINavigationController *nc = [[UINavigationController alloc] init];
//    [nc pushViewController:rootViewController animated:NO];

    [FBProfilePictureView class];
    NLSLoginViewController *viewController = [[NLSLoginViewController alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = viewController;
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Setup facebook
    [FBSettings setDefaultAppID:@"264678703732974"];
    [FBAppEvents activateApp];
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{

}

@end
