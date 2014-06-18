//
//  NLSAppDelegate.m
//  AudioApp
//
//  Created by Patrick Piemonte on 1/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NLSAppDelegate.h"

#import "PBJActivityIndicator.h"
#import "FacebookSDK.h"

@interface NLSAppDelegate ()
{
}

@end

@implementation NLSAppDelegate

@synthesize window = _window;

#pragma mark - init

#pragma mark - Launch URL

//- (void)_handleLaunchFileURL:(NSURL *)launchFileURL
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation

#pragma mark - App State Changes

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIViewController *rootViewController = [[UIViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] init];
    [nc pushViewController:rootViewController animated:NO];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = nc;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    [FBSettings setDefaultAppID:@""]; // TODO: get app id
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{

}

@end
