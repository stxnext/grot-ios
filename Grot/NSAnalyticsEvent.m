//
//  NSAnalyticsEvent.m
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSAnalyticsEvent.h"

@implementation NSAnalyticsEvent

#pragma mark - Event categories & actions
NSEventClass const kEventClassApplication          = @"application";
NSEventAction const kEventActionDidInstall         =      @"didInstall";
NSEventAction const kEventActionDidUpdate          =      @"didUpdate";
NSEventAction const kEventActionDidRun             =      @"didRun";

NSEventClass const kEventClassGameplay             = @"gameplay";
NSEventAction const kEventActionDidToggle          =      @"didToggle";
NSEventAction const kEventActionDidStart           =      @"didStart";
NSEventAction const kEventActionDidEnd             =      @"didEnd";

NSEventClass const kEventClassUserInterface        = @"userInterface";
NSEventAction const kEventActionHelpDidShow        =      @"helpDidShow";
NSEventAction const kEventActionLeaderboardDidShow =      @"leaderBoardDidShow";

NSEventClass const kEventClassGameCenter           = @"userInterface";
NSEventAction const kEventActionLoginSucceeded     =      @"loginSucceeded";
NSEventAction const kEventActionLoginFailed        =      @"loginFailed";

NSEventClass const kEventClassScreen               = @"screen";

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