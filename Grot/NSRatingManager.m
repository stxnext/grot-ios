//
//  NSRatingManager.m
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSRatingManager.h"
#import "Appirater.h"

@implementation NSRatingManager

static NSString* kApplicationPlistFilename = @"Application";
static NSString* kPlistAppStoreIdentifierKey = @"applicationAppStoreIdentifier";

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = self.class.new;
    });
    
    return singleton;
}

#pragma mark - Plist

+ (NSDictionary*)applicationPlist
{
    static NSDictionary* immutablePlist = nil;
    
    if (!immutablePlist)
    {
        NSString* path = [[NSBundle mainBundle] pathForResource:kApplicationPlistFilename ofType:@"plist"];
        immutablePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return immutablePlist;
}

#pragma mark - Manager lifecycle

- (void)start
{
    NSDictionary* plist = [self.class applicationPlist];
    NSString* appId = plist[kPlistAppStoreIdentifierKey];
    [Appirater setAppId:appId];
    [Appirater setDaysUntilPrompt:0];
    [Appirater setUsesUntilPrompt:3];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:1];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
}

- (void)resume
{
    [Appirater appEnteredForeground:YES];
}

@end
