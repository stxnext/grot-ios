//
//  SNAppDelegate.m
//  Grot
//
//  Created by Dawid Żakowski on 16/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNAppDelegate.h"
#import "UIWindow+Splash.h"

@implementation SNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Google analytics
    [SNAnalyticsManager.sharedManager start];
    [SNAnalyticsManager.sharedManager applicationDidRun];
    
    // App installation/update tracker
    [self trackAppInstallation];
    
    // Splash screen extension
    UIWindow* baseWindow = self.window;
    SplashWindow* splashWindow = [UIWindow splashWindow];
    
    self.window = splashWindow;
    [self.window makeKeyAndVisible];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.333 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [baseWindow makeKeyAndVisible];
        
        // Fade in blur
        [UIView animateWithDuration:0.999 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [splashWindow.mainImageView setAlpha:0.0];
        } completion:nil];
        
        // Fade out splash
        [UIView animateWithDuration:0.777 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            splashWindow.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.window = baseWindow;
            
            // Rating
            [Appirater setAppId:@"906596745"];
            [Appirater setDaysUntilPrompt:0];
            [Appirater setUsesUntilPrompt:3];
            [Appirater setSignificantEventsUntilPrompt:-1];
            [Appirater setTimeBeforeReminding:1];
            [Appirater setDebug:NO];
            [Appirater appLaunched:YES];
        }];
    });

    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
    
    [SNHighScoreManager.sharedManager handleHighScoreResetSetting];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [SNAnalyticsManager.sharedManager resume];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Installation and updates tracker

- (void)trackAppInstallation
{
    NSString* appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString* appBuild = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    NSString* appCombinedVersion = [NSString stringWithFormat:@"%@ %@", appVersion, appBuild];
    
    static NSString* appVersionKey = @"application.installedVersion";
    NSString* savedVersion = [NSUserDefaults.standardUserDefaults stringForKey:appVersionKey];
    BOOL isFirstInstallation = savedVersion == nil;
    BOOL appVersionChanged = ![savedVersion isEqualToString:appCombinedVersion];
    
    if (isFirstInstallation)
        [SNAnalyticsManager.sharedManager applicationDidInstall];
    else if (appVersionChanged)
        [SNAnalyticsManager.sharedManager applicationDidUpdate];
    
    [NSUserDefaults.standardUserDefaults setObject:appCombinedVersion forKey:appVersionKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

@end
