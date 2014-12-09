//
//  NSGameplayManager.m
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSGameplayManager.h"

@implementation NSGameplayManager

static NSString* kGameplayGameLaunchesCountKey = @"GameLaunchIndex";

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = self.class.new;
    });
    
    return singleton;
}

#pragma mark - Launch counter

- (NSUInteger)gameLaunchCount
{
    return [NSUserDefaults.standardUserDefaults integerForKey:kGameplayGameLaunchesCountKey];
}

- (void)incrementGameLaunchCounter
{
    NSInteger gameIndex = [self gameLaunchCount];
    NSInteger newGameIndex = gameIndex + 1;
    [NSUserDefaults.standardUserDefaults setInteger:newGameIndex forKey:kGameplayGameLaunchesCountKey];
}

@end
