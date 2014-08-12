#import "GameKitHelper.h"

@interface GameKitHelper () <GKGameCenterControllerDelegate>
{
    BOOL _gameCenterFeaturesEnabled;
}

@end

@implementation GameKitHelper

#pragma mark Singleton stuff

+ (id)sharedGameKitHelper
{
    static GameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    });
    
    return sharedGameKitHelper;
}

#pragma mark Player Authentication

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        
        [self setLastError:error];
        
        if (localPlayer.authenticated)
        {
            _gameCenterFeaturesEnabled = YES;
        }
        else if (viewController)
        {
            [self presentViewController:viewController];
        }
        else
        {
            _gameCenterFeaturesEnabled = NO;
        }
    };
}

- (BOOL)isAuthenticated
{
    return _gameCenterFeaturesEnabled;
}

#pragma mark Property setters

- (void)setLastError:(NSError*)error
{
    _lastError = [error copy];
    
    if (_lastError)
    {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
    }
}

#pragma mark UIViewController stuff

- (UIViewController *)getRootViewController
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (void)presentViewController:(UIViewController *)vc
{
    UIViewController *rootVC = [self getRootViewController];
    
    [rootVC presentViewController:vc
                         animated:YES
                       completion:nil];
}

- (void)submitScore:(int64_t)score category:(NSString*)category
{
    //1: Check if Game Center
    //   features are enabled
    if (!_gameCenterFeaturesEnabled)
    {
        NSLog(@"Player not authenticated");
        
        return;
    }
 
    //2: Create a GKScore object
    GKScore *gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:category];
    
    //3: Set the score value
    gkScore.value = score;

    //4: Send the score to Game Center

    [GKScore reportScores:@[gkScore] withCompletionHandler:^(NSError *error) {
        [self setLastError:error];
        
        BOOL success = (error == nil);
        
        if ([_delegate respondsToSelector:@selector(onScoresSubmitted:)])
        {
            [_delegate onScoresSubmitted:success];
        }
    }];
}

- (void)submitAchievement:(int64_t)score
{
    if (!_gameCenterFeaturesEnabled || score == 0)
    {
        NSLog(@"Player not authenticated");
        
        return;
    }

    NSString *achievementIdentifier = @"100_points";
    GKAchievement *scoreAchievement = nil;

    if (score >= 100) {
        achievementIdentifier = @"100_points";
    }
    
    if (score >= 200) {
        achievementIdentifier = @"200_points";
    }
    
    
    scoreAchievement = [[GKAchievement alloc] initWithIdentifier:achievementIdentifier];
    scoreAchievement.percentComplete = score;
    scoreAchievement.showsCompletionBanner = YES;
    
    NSArray *achievements = @[scoreAchievement];
    
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard category:(NSString *)category
{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard)
    {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = category;
    }
    else
    {
        gcViewController.viewState = GKGameCenterViewControllerStateAchievements;
    }
    
    [self presentViewController:gcViewController];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end