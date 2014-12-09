//
//  NSAnalyticsEvent.h
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* NSEventClass;
typedef NSString* NSEventAction;

#pragma mark - Event categories & actions
extern NSEventClass const kEventClassApplication;
extern NSEventAction const kEventActionDidInstall;
extern NSEventAction const kEventActionDidUpdate;
extern NSEventAction const kEventActionDidRun;

extern NSEventClass const kEventClassGameplay;
extern NSEventAction const kEventActionDidToggle;
extern NSEventAction const kEventActionDidStart;
extern NSEventAction const kEventActionDidEnd;

extern NSEventClass const kEventClassUserInterface;
extern NSEventAction const kEventActionHelpDidShow;
extern NSEventAction const kEventActionLeaderboardDidShow;

extern NSEventClass const kEventClassGameCenter;
extern NSEventAction const kEventActionLoginSucceeded;
extern NSEventAction const kEventActionLoginFailed;

extern NSEventClass const kEventClassScreen;

@interface NSAnalyticsEvent : NSObject

@property (nonatomic) NSEventClass class;
@property (nonatomic) NSEventAction action;
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) id value;

- (NSString*)name;
- (NSDictionary*)parameters;

@end