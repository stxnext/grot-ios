//
//  SNHighScoreManager.h
//  Grot
//
//  Created by Dawid Żakowski on 02/09/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNHighScoreManager : NSObject

+ (instancetype)sharedManager;
- (void)handleHighScoreResetSetting;
- (NSInteger)highScore;
- (void)submitHighScore:(NSInteger)score;

@end
