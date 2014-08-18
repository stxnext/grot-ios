//
//  SNAnalyticsManager.m
//  Grot
//
//  Created by Dawid Żakowski on 18/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNAnalyticsManager.h"

#ifdef DEBUG
#define CONFIGURATION_IS_DEBUG YES
#else
#define CONFIGURATION_IS_DEBUG NO
#endif

@implementation SNAnalyticsManager

static NSString *const kTrackingKey = @"GATrackingId";
static NSString *const kAllowTracking = @"GAAllowTracking";

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = self.new;
    });
    
    return singleton;
}

- (void)start
{
    NSDictionary *appDefaults = @{ kAllowTracking : @YES };
    [NSUserDefaults.standardUserDefaults registerDefaults:appDefaults];
    GAI.sharedInstance.optOut = ![NSUserDefaults.standardUserDefaults boolForKey:kAllowTracking];
    GAI.sharedInstance.dispatchInterval = 30;
    GAI.sharedInstance.trackUncaughtExceptions = YES;
    //[GAI sharedInstance].dryRun = CONFIGURATION_IS_DEBUG;
    NSString* trackingId = NSBundle.mainBundle.infoDictionary[kTrackingKey];
    _tracker = [GAI.sharedInstance trackerWithName:@"Grot" trackingId:trackingId];
}

- (void)resume
{
    [GAI sharedInstance].optOut = ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
}

- (void)sendEvent:(NSDictionary*)event
{
    NSLog(@"GA Event Triggered: %@", event);
    [_tracker send:event];
}

#pragma mark - Event trackers

- (void)gameDidEndWithScore:(NSInteger)score
{
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"gameplay"
                                                                         action:@"gameEnded"
                                                                          label:@"points"
                                                                          value:@(score)] build];
    
    [self sendEvent:event];
}

- (void)applicationDidRun
{
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"application"
                                                                         action:@"didRun"
                                                                          label:nil
                                                                          value:nil] build];
    
    [self sendEvent:event];
}

- (void)applicationDidInstall
{
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"application"
                                                                         action:@"didInstall"
                                                                          label:nil
                                                                          value:nil] build];
    
    [self sendEvent:event];
}

- (void)applicationDidUpdate
{
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"application"
                                                                         action:@"didUpdate"
                                                                          label:nil
                                                                          value:nil] build];
    
    [self sendEvent:event];
}

@end