//
//  NSAnalyticsManager.h
//  Grot
//
//  Created by Dawid Żakowski on 01/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"

@interface NSAnalyticsManager : NSObject
{
    id<GAITracker> _tracker;
    NSMutableDictionary* _pendingEvents;
}

#pragma mark - Manager lifecycle
+ (instancetype)sharedManager;
- (void)start;
- (void)resume;

#pragma mark - Triggered events
- (void)applicationDidRun;
- (void)applicationDidInstall;
- (void)applicationDidUpdate;
- (void)gameDidToggle:(BOOL)start;
- (void)gameDidStartWithIndex:(NSInteger)index;
- (void)gameDidEndWithScore:(NSInteger)score;
- (void)helpDidShow;
- (void)leaderboardDidShow;
- (void)gameCenterDidLoginWithSuccess;
- (void)gameCenterDidLoginWithFail;

@end
