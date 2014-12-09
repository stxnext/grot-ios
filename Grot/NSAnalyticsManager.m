//
//  NSAnalyticsManager.m
//  Grot
//
//  Created by Dawid Żakowski on 01/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSAnalyticsManager.h"
#import "GAIDictionaryBuilder.h"
#import "NSAnalyticsEvent.h"
#import <objc/runtime.h>

@implementation NSAnalyticsManager

static NSString* kGoogleAnalyticsTrackingId  = @"platformGoogleAnalyticsTrackingIdentifier";
static NSString* kAllowTracking = @"ApplicationAllowTracking";
static NSString* kAnalyticsPlistFilename = @"Analytics";
static NSString* kGoogleAnalyticsTrackerName = @"Grot";

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = self.new;
    });
    
    return singleton;
}

#pragma mark - Plist

+ (NSDictionary*)analyticsPlist
{
    static NSDictionary* immutablePlist = nil;
    
    if (!immutablePlist)
    {
        NSString* path = [[NSBundle mainBundle] pathForResource:kAnalyticsPlistFilename ofType:@"plist"];
        immutablePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return immutablePlist;
}

#pragma mark - Manager lifecycle

- (void)start
{
    _pendingEvents = NSMutableDictionary.dictionary;
    
    [self resume];
    
    // Google analytics
    NSDictionary* plist = [self.class analyticsPlist];
    NSString* gaTrackingId = plist[kGoogleAnalyticsTrackingId];
    GAI.sharedInstance.dispatchInterval = 30;
    GAI.sharedInstance.trackUncaughtExceptions = NO;
    
    _tracker = [GAI.sharedInstance trackerWithName:kGoogleAnalyticsTrackerName trackingId:gaTrackingId];
}

- (void)resume
{
    BOOL allowTracking = self.allowTracking;
    
    // Google analytics
    GAI.sharedInstance.optOut = !allowTracking;
}

- (BOOL)allowTracking
{
    NSDictionary* appDefaults = @{ kAllowTracking : @YES };
    [NSUserDefaults.standardUserDefaults registerDefaults:appDefaults];
    BOOL allowTracking = [NSUserDefaults.standardUserDefaults boolForKey:kAllowTracking] && !DEBUG;
    
    return allowTracking;
}

#pragma mark - Event dispatcher

- (void)triggerEvent:(NSAnalyticsEvent*)event
{
    NSLog(@"Analytics Event Triggered: %@", event.description);
    
    // Google analytics
    NSDictionary* gaEvent = [[GAIDictionaryBuilder createEventWithCategory:event.class action:event.action label:event.key value:event.value] build];
    [_tracker send:gaEvent];
}

- (void)startEvent:(NSAnalyticsEvent*)event
{
    NSLog(@"Analytics Event Started: %@", event.description);
    
    _pendingEvents[event.name] = NSDate.date;
}

- (void)endEvent:(NSAnalyticsEvent*)event
{
    NSLog(@"Analytics Event Ended: %@", event.description);
    
    // Duration calculation
    NSString* eventKey = event.name;
    NSDate* startDate = _pendingEvents[eventKey];
    [_pendingEvents removeObjectForKey:eventKey];
    NSTimeInterval duration = [NSDate.date timeIntervalSinceDate:startDate];
    
    // Google analytics
    NSDictionary* gaEvent = [[GAIDictionaryBuilder createTimingWithCategory:event.class interval:@(duration * 1000) name:event.name label:nil] build];
    [_tracker send:gaEvent];
}

#pragma mark - Event trackers

- (void)gameDidToggle:(BOOL)start
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassGameplay;
    event.action = kEventActionDidToggle;
    
    if (start)
        [self startEvent:event];
    else
        [self endEvent:event];
}

- (void)gameDidStartWithIndex:(NSInteger)index
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassGameplay;
    event.action = kEventActionDidStart;
    event.key = @"index";
    event.value = @(index);
    
    [self triggerEvent:event];
}

- (void)gameDidEndWithScore:(NSInteger)score
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassGameplay;
    event.action = kEventActionDidEnd;
    event.key = @"points";
    event.value = @(score);
    
    [self triggerEvent:event];
}

- (void)applicationDidInstall
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassApplication;
    event.action = kEventActionDidInstall;
    
    [self triggerEvent:event];
}

- (void)applicationDidUpdate
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassApplication;
    event.action = kEventActionDidUpdate;
    
    [self triggerEvent:event];
}

- (void)applicationDidRun
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassApplication;
    event.action = kEventActionDidRun;
    
    [self triggerEvent:event];
}

- (void)helpDidShow
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassUserInterface;
    event.action = kEventActionHelpDidShow;
    
    [self triggerEvent:event];
}

- (void)leaderboardDidShow
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassUserInterface;
    event.action = kEventActionLeaderboardDidShow;
    
    [self triggerEvent:event];
}


- (void)gameCenterDidLoginWithSuccess
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassGameCenter;
    event.action = kEventActionLoginSucceeded;
    
    [self triggerEvent:event];
    
}

- (void)gameCenterDidLoginWithFail
{
    NSAnalyticsEvent* event = NSAnalyticsEvent.new;
    event.class = kEventClassGameCenter;
    event.action = kEventActionLoginFailed;
    
    [self triggerEvent:event];
}

@end