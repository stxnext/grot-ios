//
//  SNHighScoreManager.m
//  Grot
//
//  Created by Dawid Żakowski on 02/09/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNHighScoreManager.h"

@implementation SNHighScoreManager

static NSString* kCustomUserHighScore = @"kCustomUserHighScore";
static NSString *const kApplicationResetHighscoreOnce = @"ApplicationResetHighscoreOnce";

+ (instancetype)sharedManager
{
    static id singleton;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        singleton = self.class.new;
    });
    
    return singleton;
}

- (void)handleHighScoreResetSetting
{
    if (self.applicationResetHighscoreOnce)
    {
        [NSUserDefaults.standardUserDefaults setInteger:0 forKey:kCustomUserHighScore];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

- (BOOL)applicationResetHighscoreOnce
{
    BOOL reset = [NSUserDefaults.standardUserDefaults boolForKey:kApplicationResetHighscoreOnce];
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:kApplicationResetHighscoreOnce];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    return reset;
}

- (NSInteger)highScore
{
    GKScore* gkScore = [GameKitHelper.sharedGameKitHelper currentPlayerScore];
    
    if (gkScore && [GameKitHelper.sharedGameKitHelper isAuthenticated])
        return (NSInteger)gkScore.value;
    
    return [NSUserDefaults.standardUserDefaults integerForKey:kCustomUserHighScore];
}

- (void)onScore:(NSInteger)score submitted:(bool)success
{
    if (success)
    {
        [GameKitHelper.sharedGameKitHelper loadCurrentPlayerScoreWithCompletionHandler:nil];
    }
    else
    {
        NSInteger highScore = [NSUserDefaults.standardUserDefaults integerForKey:kCustomUserHighScore];
        
        if (highScore < score)
        {
            [NSUserDefaults.standardUserDefaults setInteger:score forKey:kCustomUserHighScore];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
    }
}

- (void)submitHighScore:(NSInteger)score
{
    [GameKitHelper.sharedGameKitHelper setDelegate:self];
    BOOL submissionStatus = [[GameKitHelper sharedGameKitHelper] submitScore:score category:kHighScoreLeaderboardCategory];
    
    if (!submissionStatus)
        [self onScore:(NSInteger)score submitted:NO];
}

@end
