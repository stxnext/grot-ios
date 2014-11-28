//
//  NSGameCenterManager.m
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSGameCenterManager.h"

static NSString* kGameCenterPlistFilename = @"GameCenter";
static NSString* kGameCenterMainLeaderboardIdentifier = @"mainLeaderboardIdentifier";
static NSString* kGameCenterMainAchievementIdentifiers = @"mainAchievementIdentifiers";

@interface NSGameCenterManager () <GKGameCenterControllerDelegate>
@end

@implementation NSGameCenterManager

#pragma mark - Singleton

+ (instancetype)sharedManager
{
    static id singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

#pragma mark - Plist

+ (NSDictionary*)gameCenterPlist
{
    static NSDictionary* immutablePlist = nil;
    
    if (!immutablePlist)
    {
        NSString* path = [[NSBundle mainBundle] pathForResource:kGameCenterPlistFilename ofType:@"plist"];
        immutablePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return immutablePlist;
}

#pragma mark - Player

- (void)authenticatePlayerWithCompletionHandler:(void (^)(NSError* error))completionBlock
{
    if ([self playerIsAuthenticated])
    {
        if (completionBlock)
            completionBlock(nil);
        
        return;
    }
    
    GKLocalPlayer* localPlayer = GKLocalPlayer.localPlayer;
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if ([self playerIsAuthenticated])
        {
            if (completionBlock)
                completionBlock(nil);
        }
        else if (viewController)
        {
            UIViewController* topController = [self.class applicationTopController];
            [topController presentViewController:viewController animated:YES completion:nil];
        }
        else
        {
            NSError* completionError = error ?: [self.class playerUnauthorizedError];
            
            if (completionBlock)
                completionBlock(completionError);
        }
    };
}

- (void)loadLeaderboardWithIdentifier:(NSString*)identifier completionHandler:(void (^)(GKScore* score, NSError* error))completionBlock
{
    if (![self playerIsAuthenticated])
    {
        if (completionBlock)
            completionBlock(nil, [self.class playerUnauthorizedError]);
        
        return;
    }
    
    GKLocalPlayer* localPlayer = GKLocalPlayer.localPlayer;
    GKLeaderboard* leaderboardRequest = [GKLeaderboard.alloc initWithPlayerIDs:@[ localPlayer.playerID ]];
    leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
    leaderboardRequest.identifier = identifier;
    leaderboardRequest.range = NSMakeRange(0, 1);
    
    [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
        if (completionBlock)
            completionBlock(leaderboardRequest.localPlayerScore, error);
    }];
}

- (BOOL)playerIsAuthenticated
{
    return GKLocalPlayer.localPlayer.authenticated;
}

+ (NSError*)playerUnauthorizedError
{
    return [NSError errorWithDomain:GKErrorDomain code:GKErrorNotAuthenticated userInfo:nil];
}

#pragma mark - Achievements

- (void)submitAchievementWithIdentifier:(NSString*)achievementIdentifier score:(NSInteger)score completionHandler:(void (^)(NSError* error))completionBlock
{
    if (![self playerIsAuthenticated])
    {
        if (completionBlock)
            completionBlock([self.class playerUnauthorizedError]);
        
        return;
    }
    
    GKAchievement* scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
    scoreAchievement.percentComplete = score;
    scoreAchievement.showsCompletionBanner = YES;
    
    [GKAchievement reportAchievements:@[ scoreAchievement ] withCompletionHandler:^(NSError *error) {
        if (completionBlock)
            completionBlock(error);
    }];
}

- (void)showAchievements
{
    GKGameCenterViewController* controller = [[GKGameCenterViewController alloc] init];
    controller.gameCenterDelegate = self;
    controller.viewState = GKGameCenterViewControllerStateAchievements;
    
    UIViewController* topController = [self.class applicationTopController];
    [topController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Leaderboards

- (void)submitLeaderboardWithIdentifier:(NSString*)leaderboardIdentifier score:(NSInteger)score completionHandler:(void (^)(NSError* error))completionBlock
{
    if (![self playerIsAuthenticated])
    {
        if (completionBlock)
            completionBlock([self.class playerUnauthorizedError]);
        
        return;
    }
    
    GKScore* gameScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
    gameScore.value = score;
    
    [GKScore reportScores:@[ gameScore ] withCompletionHandler:^(NSError *error) {
        if (completionBlock)
            completionBlock(error);
    }];
}

- (void)showLeaderboardWithIdentifier:(NSString*)identifier
{
    GKGameCenterViewController* controller = [[GKGameCenterViewController alloc] init];
    controller.gameCenterDelegate = self;
    controller.viewState = GKGameCenterViewControllerStateLeaderboards;
    controller.leaderboardIdentifier = identifier;
    
    UIViewController* topController = [self.class applicationTopController];
    [topController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Generic

+ (UIViewController*)applicationTopController
{
    UIViewController* rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController* topController;
    
    for (topController = rootController; topController.presentedViewController; topController = topController.presentedViewController);
    
    return topController;
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController*)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Main leaderboard

+ (NSString*)mainLeaderboardIdentifier
{
    return [[self.class gameCenterPlist] objectForKey:kGameCenterMainLeaderboardIdentifier];
}

- (void)loadMainLeaderboardWithCompletionHandler:(void (^)(GKScore* score, NSError* error))completionBlock
{
    NSString* identifier = [self.class mainLeaderboardIdentifier];
    [self loadLeaderboardWithIdentifier:identifier completionHandler:completionBlock];
}

- (void)submitMainLeaderboardWithScore:(NSInteger)score completionHandler:(void (^)(NSError* error))completionBlock
{
    NSString* identifier = [self.class mainLeaderboardIdentifier];
    [self submitLeaderboardWithIdentifier:identifier score:score completionHandler:completionBlock];
}

- (void)showMainLeaderboard
{
    NSString* identifier = [self.class mainLeaderboardIdentifier];
    [self showLeaderboardWithIdentifier:identifier];
}

#pragma mark - Main achievements

+ (NSDictionary*)mainAchievementIdentifiers
{
    return [[self.class gameCenterPlist] objectForKey:kGameCenterMainAchievementIdentifiers];
}

+ (NSArray*)mainAchievementPoints
{
    return @[ @200, @400, @600, @800, @1000 ];
}

+ (NSString*)mainAchievementsIdentifierForScore:(NSInteger)score
{
    NSDictionary* achievementIdentifiers = [self.class mainAchievementIdentifiers];
    NSArray* achievementPoints = [self.class mainAchievementPoints];
    NSString* achievementIdentifier = nil;
    
    for (NSNumber* points in achievementPoints)
    {
        if (score < points.integerValue)
            break;
        
        achievementIdentifier = achievementIdentifiers[points.stringValue];
    }
    
    return achievementIdentifier;
}

- (void)submitMainAchievementWithScore:(NSInteger)score completionHandler:(void (^)(NSError* error))completionBlock
{
    NSString* identifier = [self.class mainAchievementsIdentifierForScore:score];
    [self submitAchievementWithIdentifier:identifier score:score completionHandler:completionBlock];
}

- (void)showMainAchievements
{
    [self showAchievements];
}

@end
