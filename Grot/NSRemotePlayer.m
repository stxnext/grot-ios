//
//  NSRemotePlayer.m
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSRemotePlayer.h"
#import "NSGameCenterManager.h"

@implementation NSRemotePlayer

#pragma mark - Public interface

- (void)setHighScore:(NSInteger)highScore
{
    if (highScore < self.highScore)
        return;
    
    _cachedScore = highScore;
    
    [self refreshHighScore];
}

- (NSInteger)highScore
{
    return _cachedScore;
}

#pragma mark - Synchronization

- (void)refreshHighScore
{
    if ([self isConnected])
    {
        [[NSGameCenterManager sharedManager] loadMainLeaderboardWithCompletionHandler:^(GKScore *score, NSError *error) {
            if (!error && score.value > _cachedScore)
            {
                _cachedScore = (NSInteger)score.value;
            }
        }];
    }
}

- (BOOL)isConnected
{
    return [[NSGameCenterManager sharedManager] playerIsAuthenticated];
}

@end