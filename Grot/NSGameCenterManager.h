//
//  NSGameCenterManager.h
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;

extern NSString* kGameCenterAuthorizationNotificationKey;

@interface NSGameCenterManager : NSObject

#pragma mark - Singleton
+ (instancetype)sharedManager;

#pragma mark - Player
- (void)authenticatePlayer;
- (void)loadLeaderboardWithIdentifier:(NSString*)identifier completionHandler:(void (^)(GKScore* score, NSError* error))completionBlock;
- (BOOL)playerIsAuthenticated;

#pragma mark - Main leaderboard
- (void)loadMainLeaderboardWithCompletionHandler:(void (^)(GKScore* score, NSError* error))completionBlock;
- (void)submitMainLeaderboardWithScore:(NSInteger)score completionHandler:(void (^)(NSError* error))completionBlock;
- (void)showMainLeaderboard;

#pragma mark - Main achievements
+ (NSArray*)mainAchievementPoints;
- (void)submitMainAchievementWithScore:(NSInteger)score completionHandler:(void (^)(NSError* error))completionBlock;
- (void)showMainAchievements;

@end
