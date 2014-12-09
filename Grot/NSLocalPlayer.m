//
//  NSLocalPlayer.m
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSLocalPlayer.h"

@implementation NSLocalPlayer

static NSString* kUserDefaultsHighScoreKey = @"kCustomUserHighScore";

#pragma mark - Public interface

- (void)setHighScore:(NSInteger)highScore
{
    if (highScore < self.highScore)
        return;
    
    [NSUserDefaults.standardUserDefaults setInteger:highScore forKey:kUserDefaultsHighScoreKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (NSInteger)highScore
{
    return [NSUserDefaults.standardUserDefaults integerForKey:kUserDefaultsHighScoreKey];
}

@end