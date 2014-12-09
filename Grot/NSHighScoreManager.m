//
//  NSHighScoreManager.m
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSHighScoreManager.h"

@implementation NSHighScoreManager

static NSString* kApplicationResetHighscoreOnce = @"ApplicationResetHighscoreOnce";

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _localUser = [NSLocalPlayer new];
        _localUser.highScore = 0;
        
        _remoteUser = [NSRemotePlayer new];
        _remoteUser.highScore = 0; // calls refresh implicitly
    }
    
    return self;
}

#pragma mark - Remote user

- (void)refreshRemoteUser
{
    [_remoteUser refreshHighScore];
}

#pragma mark - Local user

- (void)wipeLocalUserIfNeeded
{
    if (self.applicationResetHighscoreOnce)
    {
        _localUser.highScore = 0;
    }
}

- (BOOL)applicationResetHighscoreOnce
{
    BOOL reset = [[NSUserDefaults standardUserDefaults] boolForKey:kApplicationResetHighscoreOnce];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kApplicationResetHighscoreOnce];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return reset;
}

#pragma mark - Transparent user

- (void)setHighScore:(NSInteger)highScore
{
    if ([_remoteUser isConnected])
    {
        [_remoteUser setHighScore:highScore];
    }
    else
    {
        [_localUser setHighScore:highScore];
    }
}

- (NSInteger)highScore
{
    if ([_remoteUser isConnected])
    {
        return [_remoteUser highScore];
    }
    else
    {
        return [_localUser highScore];
    }
}

@end
