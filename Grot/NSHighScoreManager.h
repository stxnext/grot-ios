//
//  NSHighScoreManager.h
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;

@interface NSHighScoreManager : NSObject
{
    GKScore* _gameCenterHighScore;
    NSNumber* _cachedGameCenterHighScore;
}

+ (instancetype)sharedManager;

- (void)refreshGameCenterHighScore;

@property (nonatomic) NSInteger highScore;

@end
