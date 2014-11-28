//
//  NSGameCenterManager.h
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;

typedef NS_OPTIONS(NSUInteger, NSGameCenterSubmissionStatus) {
    NSGameCenterSubmissionSuccess = 0,
    NSGameCenterSubmissionLeaderboardFailure = 1 << 0,
    NSGameCenterSubmissionAchievementsFailure = 1 << 1,
    NSGameCenterSubmissionCompleteFailure = 3
};

@interface NSGameCenterManager : NSObject

#pragma mark - Singleton
+ (instancetype)sharedManager;

#pragma mark - Player
- (void)authenticatePlayerWithCompletionHandler:(void (^)(NSError* error))completionBlock;
- (void)loadLeaderboardWithIdentifier:(NSString*)identifier completionHandler:(void (^)(GKScore* score, NSError* error))completionBlock;
- (BOOL)playerIsAuthenticated;

#pragma mark - Main leaderboard
- (void)loadMainLeaderboardWithCompletionHandler:(void (^)(GKScore* score, NSError* error))completionBlock;
- (void)submitMainLeaderboardWithScore:(NSInteger)score completionHandler:(void (^)(NSError* error))completionBlock;
- (void)showMainLeaderboard;

#pragma mark - Main achievements
- (void)submitMainAchievementWithScore:(NSInteger)score completionHandler:(void (^)(NSError* error))completionBlock;
- (void)showMainAchievements;

#pragma mark - Combined score submission
- (void)submitMainScore:(NSInteger)score completionHandler:(void (^)(NSGameCenterSubmissionStatus status, NSDictionary* errors))completionBlock;

@end
