//
//  NSUpdateManager.m
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSUpdateManager.h"
#import "NSAnalyticsManager.h"

@implementation NSUpdateManager

static NSString* kApplicationLastInstalledVersion = @"application.installedVersion";

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = self.class.new;
    });
    
    return singleton;
}

- (void)trigerApplicationUpdateEventsIfNeeded
{
    NSString* appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString* appBuild = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    NSString* appCombinedVersion = [NSString stringWithFormat:@"%@ %@", appVersion, appBuild];
    
    NSString* appVersionKey = kApplicationLastInstalledVersion;
    NSString* savedVersion = [NSUserDefaults.standardUserDefaults stringForKey:appVersionKey];
    BOOL isFirstInstallation = savedVersion == nil;
    BOOL appVersionChanged = ![savedVersion isEqualToString:appCombinedVersion];
    
    if (isFirstInstallation)
        [[NSAnalyticsManager sharedManager] applicationDidInstall];
    else if (appVersionChanged)
        [[NSAnalyticsManager sharedManager] applicationDidUpdate];
    
    [NSUserDefaults.standardUserDefaults setObject:appCombinedVersion forKey:appVersionKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

@end
