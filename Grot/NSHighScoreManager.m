//
//  NSHighScoreManager.m
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSHighScoreManager.h"
#import "NSGameCenterManager.h"

@implementation NSHighScoreManager

static NSString* kUserDefaultsHighScoreKey = @"userDefaultsHighScoreKey";

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (void)refreshGameCenterHighScore
{
    [[NSGameCenterManager sharedManager] authenticatePlayerWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            return;
        }
        
        [[NSGameCenterManager sharedManager] loadMainLeaderboardWithCompletionHandler:^(GKScore *score, NSError *error) {
            _gameCenterHighScore = score;
            
            if (!error)
            {
                _cachedGameCenterHighScore = nil;
            }
        }];
    }];
}

- (void)setHighScore:(NSInteger)highScore
{
    if (highScore <= self.highScore)
        return;
    
    GKPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    if (localPlayer)
    {
        _cachedGameCenterHighScore = @(highScore);
        [self refreshGameCenterHighScore];
    }
    else
        [self setStorageHighScore:highScore];
}

- (NSInteger)highScore
{
    GKPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    if (_cachedGameCenterHighScore)
    {
        return _cachedGameCenterHighScore.integerValue;
    }
    else if (_gameCenterHighScore && [_gameCenterHighScore.playerID isEqualToString:localPlayer.playerID])
    {
        return _gameCenterHighScore.value;
    }
    
    return [self storageHighScore];
}

- (void)setStorageHighScore:(NSInteger)highScore
{
    [NSUserDefaults.standardUserDefaults setInteger:highScore forKey:kUserDefaultsHighScoreKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSInteger)storageHighScore
{
    return [NSUserDefaults.standardUserDefaults integerForKey:kUserDefaultsHighScoreKey];
}

@end
