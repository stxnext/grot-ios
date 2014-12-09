//
//  AppDelegate.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "AppDelegate.h"
#import "NSGameCenterManager.h"
#import "NSHighScoreManager.h"
#import "NSAnalyticsManager.h"
#import "NSRatingManager.h"
#import "NSUpdateManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Google analytics
    [NSAnalyticsManager.sharedManager start];
    [NSAnalyticsManager.sharedManager applicationDidRun];
    
    // App installation/update tracker
    [[NSUpdateManager sharedManager] trigerApplicationUpdateEventsIfNeeded];
    
    // Refresh highscores whenever authentication changes
    [[NSNotificationCenter defaultCenter] addObserverForName:kGameCenterAuthorizationNotificationKey object:nil queue:nil usingBlock:^(NSNotification *note) {
        [[NSHighScoreManager sharedManager] refreshRemoteUser];
    }];
    
    // Start authenticating game center player
    [[NSGameCenterManager sharedManager] authenticatePlayer];
    
    // Application rating
    [[NSRatingManager sharedManager] start];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSAnalyticsManager sharedManager] resume];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSRatingManager sharedManager] resume];
    
    [[NSHighScoreManager sharedManager] wipeLocalUserIfNeeded];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return INTERFACE_IS_PAD ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

@end
