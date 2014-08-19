//
//  SNAnalyticsManager.m
//  Grot
//
//  Created by Dawid Żakowski on 18/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNAnalyticsManager.h"
#import <objc/runtime.h>

#ifdef DEBUG
#define CONFIGURATION_IS_DEBUG YES
#else
#define CONFIGURATION_IS_DEBUG NO
#endif

@interface GAITrackedViewController (SNAnalytics)
@end

@implementation GAITrackedViewController (SNAnalytics)

static NSString* const kNotificationViewControllerDidAppear     = @"notificationViewControllerDidAppear";
static NSString* const kNotificationViewControllerWillDisappear = @"notificationViewControllerWillDisappear";

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.class swizzleSelector:@selector(viewDidAppear:) with:@selector(s_viewDidAppear:)];
        [self.class swizzleSelector:@selector(viewWillDisappear:) with:@selector(s_viewWillDisappear:)];
        [self.class swizzleSelector:@selector(initWithCoder:) with:@selector(s_initWithCoder:)];
    });
}

+ (void)swizzleSelector:(SEL)originalSelector with:(SEL)targetSelector
{
    Class class = self.class;
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, targetSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod)
        class_replaceMethod(class, targetSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    else
        method_exchangeImplementations(originalMethod, swizzledMethod);
}

#pragma mark - Method Swizzling

- (void)s_viewDidAppear:(BOOL)animated
{
    [self s_viewDidAppear:animated];
    
    [NSNotificationCenter.defaultCenter postNotificationName:kNotificationViewControllerDidAppear object:self];
}

- (void)s_viewWillDisappear:(BOOL)animated
{
    [self s_viewWillDisappear:animated];
    
    [NSNotificationCenter.defaultCenter postNotificationName:kNotificationViewControllerWillDisappear object:self];
}

- (id)s_initWithCoder:(NSCoder*)aDecoder
{
    GAITrackedViewController* this = [self s_initWithCoder:aDecoder];
    
    this.screenName = NSStringFromClass(self.class);
    
    return this;
}

@end

@interface SNAnalyticsEvent : NSObject

typedef NSString* SNEventClass;
typedef NSString* SNEventAction;

@property (nonatomic) SNEventClass class;
@property (nonatomic) SNEventAction action;
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) id value;

- (NSString*)name;
- (NSDictionary*)parameters;

@end

@implementation SNAnalyticsEvent

#pragma mark - Event categories & actions
static SNEventClass const kEventClassApplication   = @"application";
static SNEventAction const kEventActionDidInstall  =      @"didInstall";
static SNEventAction const kEventActionDidUpdate   =      @"didUpdate";
static SNEventAction const kEventActionDidRun      =      @"didRun";

static SNEventClass const kEventClassGameplay      = @"gameplay";
static SNEventAction const kEventActionDidToggle   =      @"didToggle";
static SNEventAction const kEventActionDidEnd      =      @"didEnd";

static SNEventClass const kEventClassScreen        = @"screen";

#pragma mark - Object description

- (NSString*)name
{
    if (!self.action)
        return self.class;
    else
        return [NSString stringWithFormat:@"%@.%@", self.class, self.action];
}

- (NSDictionary*)parameters
{
    if (!self.key || !self.value)
        return nil;
    else
        return @{ self.key : self.value };
}

- (NSString*)description
{
    NSDictionary* parameters = self.parameters;
    
    if (!parameters)
        return self.name;
    else
        return [NSString stringWithFormat:@"%@ %@", self.name, self.parameters];
}

@end

@implementation SNAnalyticsManager

static NSString *const kGATrackingId  = @"GATrackingId";
static NSString *const kFlurryAPIKey  = @"FlurryTrackingKey";
static NSString *const kAllowTracking = @"ApplicationAllowTracking";

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = self.new;
    });
    
    return singleton;
}

#pragma mark - Manager lifecycle

- (void)start
{
    _pendingEvents = NSMutableDictionary.dictionary;
    
    [self resume];
    
    // Google analytics
    NSString* gaTrackingId = NSBundle.mainBundle.infoDictionary[kGATrackingId];
    GAI.sharedInstance.dispatchInterval = 30;
    GAI.sharedInstance.trackUncaughtExceptions = NO;
    _tracker = [GAI.sharedInstance trackerWithName:@"Grot" trackingId:gaTrackingId];
    
    // Flurry
    NSString* flurryTrackingId = NSBundle.mainBundle.infoDictionary[kFlurryAPIKey];
    [Flurry setCrashReportingEnabled:YES];
    [Flurry setSecureTransportEnabled:YES];
    [Flurry startSession:flurryTrackingId];
    
    // View controller lifecycle notifications
    [NSNotificationCenter.defaultCenter addObserverForName:kNotificationViewControllerDidAppear object:nil queue:nil usingBlock:^(NSNotification *note) {
        UIViewController* sender = note.object;
        [self viewController:sender changedVisibility:YES];
    }];
    
    [NSNotificationCenter.defaultCenter addObserverForName:kNotificationViewControllerWillDisappear object:nil queue:nil usingBlock:^(NSNotification *note) {
        UIViewController* sender = note.object;
        [self viewController:sender changedVisibility:NO];
    }];
}

- (void)resume
{
    BOOL allowTracking = self.allowTracking;
    
    // Google analytics
    GAI.sharedInstance.optOut = !allowTracking;
    
    // Flurry
    [Flurry setSessionReportsOnPauseEnabled:allowTracking];
    [Flurry setSessionReportsOnCloseEnabled:allowTracking];
}

- (BOOL)allowTracking
{
    NSDictionary* appDefaults = @{ kAllowTracking : @YES };
    [NSUserDefaults.standardUserDefaults registerDefaults:appDefaults];
    BOOL allowTracking = [NSUserDefaults.standardUserDefaults boolForKey:kAllowTracking]/* && !CONFIGURATION_IS_DEBUG*/;
    
    return allowTracking;
}

#pragma mark - Event dispatcher

- (void)triggerEvent:(SNAnalyticsEvent*)event
{
    NSLog(@"Analytics Event Triggered: %@", event.description);
    
    // Google analytics
    NSDictionary* gaEvent = [[GAIDictionaryBuilder createEventWithCategory:event.class action:event.action label:event.key value:event.value] build];
    [_tracker send:gaEvent];
    
    // Flurry
    [Flurry logEvent:event.name withParameters:event.parameters];
}

- (void)startEvent:(SNAnalyticsEvent*)event
{
    NSLog(@"Analytics Event Started: %@", event.description);
    
    _pendingEvents[event.name] = NSDate.date;
    
    [Flurry logEvent:event.name withParameters:event.parameters timed:YES];
}

- (void)endEvent:(SNAnalyticsEvent*)event
{
    NSLog(@"Analytics Event Ended: %@", event.description);
    
    // Duration calculation
    NSString* eventKey = event.name;
    NSDate* startDate = _pendingEvents[eventKey];
    [_pendingEvents removeObjectForKey:eventKey];
    NSTimeInterval duration = [NSDate.date timeIntervalSinceDate:startDate];
    
    // Google analytics
    NSDictionary* gaEvent = [[GAIDictionaryBuilder createTimingWithCategory:event.class interval:@(duration) name:event.name label:nil] build];
    [_tracker send:gaEvent];
    
    // Flurry
    [Flurry endTimedEvent:event.name withParameters:nil];
}

- (void)viewController:(UIViewController*)vc changedVisibility:(BOOL)visible
{
    if ([vc isKindOfClass:GAITrackedViewController.class])
    {
        GAITrackedViewController* gaVc = (GAITrackedViewController*)vc;
        SNAnalyticsEvent* event = SNAnalyticsEvent.new;
        event.class = kEventClassScreen;
        event.action = gaVc.screenName;
        
        if (visible)
            [Flurry logEvent:event.name withParameters:nil timed:YES];
        else
            [Flurry endTimedEvent:event.name withParameters:nil];
    }
}

#pragma mark - Event trackers

- (void)gameDidToggle:(BOOL)start
{
    SNAnalyticsEvent* event = SNAnalyticsEvent.new;
    event.class = kEventClassGameplay;
    event.action = kEventActionDidToggle;
    
    if (start)
        [self startEvent:event];
    else
        [self endEvent:event];
}

- (void)gameDidEndWithScore:(NSInteger)score
{
    SNAnalyticsEvent* event = SNAnalyticsEvent.new;
    event.class = kEventClassGameplay;
    event.action = kEventActionDidEnd;
    event.key = @"points";
    event.value = @(score);
    
    [self triggerEvent:event];
}

- (void)applicationDidInstall
{
    SNAnalyticsEvent* event = SNAnalyticsEvent.new;
    event.class = kEventClassApplication;
    event.action = kEventActionDidInstall;
    
    [self triggerEvent:event];
}

- (void)applicationDidUpdate
{
    SNAnalyticsEvent* event = SNAnalyticsEvent.new;
    event.class = kEventClassApplication;
    event.action = kEventActionDidUpdate;
    
    [self triggerEvent:event];
}

- (void)applicationDidRun
{
    SNAnalyticsEvent* event = SNAnalyticsEvent.new;
    event.class = kEventClassApplication;
    event.action = kEventActionDidRun;
    
    [self triggerEvent:event];
}

@end