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
#import "Flurry.h"

@interface SNAnalyticsManager : NSObject
{
    id<GAITracker> _tracker;
    NSMutableDictionary* _pendingEvents;
}

+ (instancetype)sharedManager;
- (void)start;
- (void)resume;

- (void)gameDidToggle:(BOOL)start;
- (void)gameDidEndWithScore:(NSInteger)score;
- (void)applicationDidRun;
- (void)applicationDidInstall;
- (void)applicationDidUpdate;

@end
