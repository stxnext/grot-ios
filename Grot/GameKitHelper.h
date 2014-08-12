//
//  GameKitHelper.h
//  Grot
//
//  Created by Adam on 07.08.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

//   Include the GameKit framework
#import <GameKit/GameKit.h>

#define kHighScoreLeaderboardCategory @"com.stxnext.Grot.HighScores"

//   Protocol to notify external
//   objects when Game Center events occur or
//   when Game Center async tasks are completed
@protocol GameKitHelperProtocol<NSObject>
- (void)onScoresSubmitted:(bool)success;
@end


@interface GameKitHelper : NSObject

@property (nonatomic, assign)
id<GameKitHelperProtocol> delegate;

// This property holds the last known error
// that occured while using the Game Center API's
@property (nonatomic, readonly) NSError *lastError;

+ (id)sharedGameKitHelper;

- (BOOL)isAuthenticated;
- (void)authenticateLocalPlayer;
- (void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard category:(NSString*)category;
- (void)submitScore:(int64_t)score category:(NSString *)category;
- (void)submitAchievement:(int64_t)score;

@end