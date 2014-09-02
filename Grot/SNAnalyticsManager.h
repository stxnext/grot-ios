//
//  SNAnalyticsManager.h
//  Grot
//
//  Created by Dawid Żakowski on 18/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

//#define USE_FLURRY

#ifdef USE_FLURRY
#import "Flurry.h"
#endif

@interface SNAnalyticsManager : NSObject
{
    id<GAITracker> _tracker;
    NSMutableDictionary* _pendingEvents;
}

+ (instancetype)sharedManager;
- (void)start;
- (void)resume;

- (void)gameDidToggle:(BOOL)start;
- (void)gameDidStartWithIndex:(NSInteger)index;
- (void)gameDidEndWithScore:(NSInteger)score;
- (void)applicationDidRun;
- (void)applicationDidInstall;
- (void)applicationDidUpdate;
- (void)helpDidShow;
- (void)leaderboardDidShow;
- (void)gameCenterDidLoginWithSuccess;
- (void)gameCenterDidLoginWithFail;

@end
