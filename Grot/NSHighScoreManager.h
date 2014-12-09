//
//  NSHighScoreManager.h
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSLocalPlayer.h"
#import "NSRemotePlayer.h"

@import GameKit;

@interface NSHighScoreManager : NSObject
{
    NSLocalPlayer* _localUser;
    NSRemotePlayer* _remoteUser;
}

+ (instancetype)sharedManager;

- (void)refreshRemoteUser;
- (void)wipeLocalUserIfNeeded;;

@property (nonatomic) NSInteger highScore;

@end
