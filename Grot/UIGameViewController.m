//
//  UIGameViewController.m
//  Grot
//
//  Created by Dawid Żakowski on 09/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIGameViewController.h"
#import "UIGameStoryboard.h"
#import "UIFloatingMenuController.h"
#import "UIFloatingHelpController.h"
#import "UIView+RoundedEdges.h"
#import "NSGameCenterManager.h"
#import "NSObject+SafeBlocks.h"
#import "UIAlertView+BlocksKit.h"
#import "NSHighScoreManager.h"
#import "UIView+CancellationToken.h"
#import "NSAnalyticsManager.h"
#import "NSGameplayManager.h"
#import "NSConcurrentOperation.h"

static NSString* kGameControllerPlistFilename = @"GameController";
static NSString* kGameInitialScoreKey = @"gameInitialScore";
static NSString* kGameInitialMovesKey = @"gameInitialMoves";
static NSString* kGameGridSizeWidthKey = @"gameGridSizeWidth";
static NSString* kGameGridSizeHeightKey = @"gameGridSizeHeight";

@implementation UIGameViewController

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _playgroundChildController.view.backgroundColor = self.view.backgroundColor;
    _playgroundChildController.delegate = self;
    
    if (INTERFACE_IS_PHONE)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_playgroundChildController.gameState)
    {
        [self restartGame];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.pauseButton applyRoundedEdges];
    [self.helpButton applyRoundedEdges];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.destinationViewController isKindOfClass:[UIPlaygroundGridViewController class]])
    {
        _playgroundChildController = segue.destinationViewController;
    }
    else if ([segue.destinationViewController isKindOfClass:[UIFloatingMenuController class]])
    {
        __weak UIFloatingMenuController* weakMenu = (UIFloatingMenuController*)segue.destinationViewController;
        
        weakMenu.menuButtonSelectionBlock = ^(UIFloatingMenuButtonTag option) {
            switch (option)
            {
                case UIFloatingMenuButtonResumeTag:
                {
                    [weakMenu dismissWithCompletionHandler:^{
                        
                    }];
                    
                    break;
                }
                    
                case UIFloatingMenuButtonRestartTag:
                {
                    [weakMenu dismissWithCompletionHandler:^{
                        [self restartGame];
                    }];
                    
                    break;
                }
                    
                case UIFloatingMenuButtonGameCenterTag:
                {
                    [[NSGameCenterManager sharedManager] showMainLeaderboard];
                    break;
                }
                    
                case UIFloatingMenuButtonInstructionsTag:
                {
                    [weakMenu performSegueWithIdentifier:kMenuHelpSegueIdentifier sender:nil];
                    
                    break;
                }
            }
        };
    }
    else if ([segue.destinationViewController isKindOfClass:[UIFloatingHelpController class]])
    {
        __weak UIFloatingHelpController* weakMenu = (UIFloatingHelpController*)segue.destinationViewController;
        
        weakMenu.menuButtonSelectionBlock = ^(UIFloatingHelpButtonTag option) {
            switch (option)
            {
                case UIFloatingHelpButtonReturnTag:
                {
                    [weakMenu dismissWithCompletionHandler:nil];
                    
                    break;
                }
            }
        };
    }
    else if ([segue.destinationViewController isKindOfClass:[UIFloatingResultController class]])
    {
        __weak UIFloatingResultController* weakMenu = (UIFloatingResultController*)segue.destinationViewController;
        
        weakMenu.dataSource = self;
        
        weakMenu.menuButtonSelectionBlock = ^(UIFloatingResultButtonTag option) {
            switch (option)
            {
                case UIFloatingResultButtonRestartTag:
                {
                    [weakMenu dismissWithCompletionHandler:^{
                        [self restartGame];
                    }];
                    
                    break;
                }
                    
                case UIFloatingResultButtonGameCenterTag:
                {
                    [[NSGameCenterManager sharedManager] showMainLeaderboard];
                    break;
                }
            }
        };
    }
}

#pragma mark - Plist

+ (NSDictionary*)gameControllerPlist
{
    static NSDictionary* immutablePlist = nil;
    
    if (!immutablePlist)
    {
        NSString* path = [[NSBundle mainBundle] pathForResource:kGameControllerPlistFilename ofType:@"plist"];
        immutablePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return immutablePlist;
}

#pragma mark - Interface orientation

- (void)interfaceOrientationChanged:(NSNotification*)notification
{
    UIDevice* device = notification.object;
    UIDeviceOrientation orientation = device.orientation;
    
    if (orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationFaceUp)
        return;
    
    NSArray* rotableViews = @[ self.scoreContainer, self.movesContainer, self.pauseButton, self.helpButton, self.heroIcon ];
    CGFloat angle;
    
    switch (orientation)
    {
        case UIDeviceOrientationPortrait: angle = 0.0; break;
        case UIDeviceOrientationPortraitUpsideDown: return;
        case UIDeviceOrientationLandscapeRight: angle = -M_PI_2; break;
        case UIDeviceOrientationLandscapeLeft: angle = M_PI_2; break;
        default: angle = 0.0;
    }
    
    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
        for (UIView* view in rotableViews)
            view.transform = CGAffineTransformMakeRotation(angle);
    }];
}

#pragma mark - Game cycle

- (void)restartGame
{
    [[NSGameplayManager sharedManager] incrementGameLaunchCounter];
    
    NSInteger launchCount = [[NSGameplayManager sharedManager] gameLaunchCount];
    [NSAnalyticsManager.sharedManager gameDidStartWithIndex:launchCount];
    [NSAnalyticsManager.sharedManager gameDidToggle:YES];
    
    NSDictionary* plist = [self.class gameControllerPlist];
    CGSize gridSize = CGSizeMake([plist[kGameGridSizeWidthKey] integerValue], [plist[kGameGridSizeHeightKey] integerValue]);
    NSInteger initialScore = [plist[kGameInitialScoreKey] integerValue];
    NSInteger initialMoves = [plist[kGameInitialMovesKey] integerValue];
    [_playgroundChildController restartGameWithGridSize:gridSize initialScore:initialScore initialMoves:initialMoves];
}

- (void)gameDidEndWithScore:(NSInteger)score
{
    [NSAnalyticsManager.sharedManager gameDidToggle:NO];
    [NSAnalyticsManager.sharedManager gameDidEndWithScore:score];
    
    [self submitGameCenterLeaderboardScore:score withCompletionHandler:nil];
    
    [self performSegueWithIdentifier:kMenuResultsSegueIdentifier sender:self];
}

#pragma mark - Playground delegate

- (void)playgroundController:(UIPlaygroundGridViewController*)controller didDeductPenaltyFromState:(NSGameState*)fromState toState:(NSGameState*)toState
{
    NSInteger moves = toState.results.moves;
    NSInteger delta = toState.results.moves - fromState.results.moves;
    
    [self.class animateCounter:self.movesCounter toValue:moves withAnimationSpeed:1.0 displayingDelta:YES withValueDelta:delta inDeltaLabel:self.movesDeltaCounter completionHandler:nil];
}

- (void)playgroundController:(UIPlaygroundGridViewController*)controller willStartReaction:(NSFieldReaction*)reaction
{
    if (reaction.targetState.results.moves == 0)
    {
        self.view.userInteractionEnabled = NO;
    }
}

- (void)playgroundController:(UIPlaygroundGridViewController*)controller didChangeFromResults:(NSGameResults*)fromResults toResults:(NSGameResults*)toResults
{
    NSInteger visibleMoves = MAX(0, toResults.moves);
    
    NSInteger scoreDelta = toResults.score - fromResults.score;
    NSInteger movesDelta = toResults.moves - fromResults.moves;
    
    BOOL shouldDisplayScoreDelta = toResults.score > 1;
    BOOL shouldDisplayMovesDelta = toResults.score > 1;
    
    CGFloat scoreCounterSpeed = scoreDelta != 0 ? 1.0 : CGFLOAT_MAX;
    CGFloat movesCounterSpeed = movesDelta != 0 ? 1.0 : CGFLOAT_MAX;
    
    NSOperationQueue* queue = [NSOperationQueue new];
    queue.suspended = YES;
    
    if (scoreDelta != 0)
    {
        [queue addConcurrentOperationWithBlock:^(dispatch_block_t callback) {
            [self.class animateCounter:self.scoreCounter
                               toValue:toResults.score
                    withAnimationSpeed:scoreCounterSpeed
                       displayingDelta:shouldDisplayScoreDelta
                        withValueDelta:scoreDelta
                          inDeltaLabel:self.scoreDeltaCounter
                     completionHandler:callback];
        }];
    }
    
    if (movesDelta != 0)
    {
        [queue addConcurrentOperationWithBlock:^(dispatch_block_t callback) {
            [self.class animateCounter:self.movesCounter
                               toValue:visibleMoves
                    withAnimationSpeed:movesCounterSpeed
                       displayingDelta:shouldDisplayMovesDelta
                        withValueDelta:movesDelta
                          inDeltaLabel:self.movesDeltaCounter
                     completionHandler:callback];
        }];
    }
    
    [queue setPendingOperationsCompletionHandler:^{
        if (visibleMoves <= 0)
        {
            [self gameDidEndWithScore:toResults.score];
            self.view.userInteractionEnabled = YES;
        }
    }];
    
    queue.suspended = NO;
    
    [self submitGameCenterAchievementFromScore:fromResults.score toScore:toResults.score withCompletionHandler:nil];
}

#pragma mark - Counter animations

+ (void)animateCounter:(UICounterLabel*)counter
               toValue:(NSInteger)value
    withAnimationSpeed:(CGFloat)animationSpeed
       displayingDelta:(BOOL)shouldDisplayDelta
        withValueDelta:(NSInteger)valueDelta
          inDeltaLabel:(UILabel*)deltaLabel
     completionHandler:(dispatch_block_t)completionBlock
{
    NSCancellationToken* token;
    
    @synchronized (counter)
    {
        if (counter.cancellationToken)
        {
            @synchronized (counter.cancellationToken)
            {
                counter.cancellationToken.isCancelled = YES;
                [counter.layer removeAllAnimations];
                [deltaLabel.layer removeAllAnimations];
                [counter finishAnimation];
                
                counter.layer.transform = CATransform3DIdentity;
                deltaLabel.alpha = 0.0;
            }
        }
        
        token = counter.cancellationToken = [NSCancellationToken new];
    }
    
    [self animateCounter:counter
                 toValue:value
      withAnimationSpeed:animationSpeed
         displayingDelta:shouldDisplayDelta
          withValueDelta:valueDelta
            inDeltaLabel:deltaLabel
       cancellationToken:token
       completionHandler:completionBlock];
}

+ (void)animateCounter:(UICounterLabel*)counter
               toValue:(NSInteger)value
    withAnimationSpeed:(CGFloat)animationSpeed
       displayingDelta:(BOOL)shouldDisplayDelta
        withValueDelta:(NSInteger)valueDelta
          inDeltaLabel:(UILabel*)deltaLabel
     cancellationToken:(NSCancellationToken*)token
     completionHandler:(dispatch_block_t)completionBlock
{
    if (shouldDisplayDelta)
    {
        [UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CATransform3D transform = CATransform3DMakeTranslation(0.0, -0.2 * counter.frame.size.height, 0.0);
            transform = CATransform3DScale(transform, 0.8, 0.8, 1.0);
            counter.layer.transform = transform;
        } completion:^(BOOL finished) {
            @synchronized (token)
            {
                if (token.isCancelled || !finished)
                {
                    if (completionBlock)
                        completionBlock();
                    
                    return;
                }
                
                [counter setValue:value animationSpeed:animationSpeed completionHandler:completionBlock];
                
                [UIView animateWithDuration:0.66 delay:0.99 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    counter.layer.transform = CATransform3DIdentity;
                } completion:nil];
            }
        }];
        
        deltaLabel.alpha = 0.5;
        deltaLabel.layer.transform = CATransform3DMakeScale(0.01, 0.01, 1.0);
        deltaLabel.text = [NSString stringWithFormat:@"%@%d", valueDelta >= 0 ? @"+" : @"", (int)valueDelta];
        
        [UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            deltaLabel.alpha = 1.0;
            deltaLabel.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
            @synchronized (token)
            {
                if (token.isCancelled || !finished)
                    return;
                
                [UIView animateWithDuration:0.66 delay:0.66 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    deltaLabel.alpha = 0.0;
                } completion:nil];
            }
        }];
    }
    else
    {
        [counter setValue:value animationSpeed:animationSpeed completionHandler:completionBlock];
    }
}

#pragma mark - UIFloatingResultControllerDataSource

- (NSInteger)resultControllerCurrentScore
{
    return _playgroundChildController.gameState.results.score;
}

- (NSInteger)resultControllerHighScore
{
    return [[NSHighScoreManager sharedManager] highScore];
}

#pragma mark - Game Center

- (void)submitGameCenterLeaderboardScore:(NSInteger)score withCompletionHandler:(void (^)())completionBlock
{
    if (![[NSGameCenterManager sharedManager] playerIsAuthenticated])
    {
        if (completionBlock)
            completionBlock();
        
        return;
    }
    
    [self.class performBlock:^(dispatch_block_t safeBlock) {
        [[NSGameCenterManager sharedManager] submitMainLeaderboardWithScore:score completionHandler:^(NSError *error) {
            if (error)
            {
                [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Problem", nil)
                                               message:NSLocalizedString(@"Could not submit your score.", nil)
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                     otherButtonTitles:@[ NSLocalizedString(@"Retry", nil) ] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                         if (buttonIndex == 1)
                                         {
                                             safeBlock();
                                             return;
                                         }
                                         
                                         if (completionBlock)
                                             completionBlock();
                                     }];
                
                return;
            }
            
            if (completionBlock)
                completionBlock();
        }];
    }];
}

- (void)submitGameCenterAchievementFromScore:(NSInteger)fromScore toScore:(NSInteger)toScore withCompletionHandler:(void (^)())completionBlock
{
    NSArray* achievementPointsDistribution = [NSGameCenterManager mainAchievementPoints];
    BOOL shouldSubmit = NO;
    
    for (NSNumber* point in achievementPointsDistribution)
    {
        if (fromScore < point.integerValue && point.integerValue <= toScore)
        {
            shouldSubmit = YES;
            break;
        }
    }
    
    if (!shouldSubmit || ![[NSGameCenterManager sharedManager] playerIsAuthenticated])
    {
        if (completionBlock)
            completionBlock();
        
        return;
    }
    
    [self.class performBlock:^(dispatch_block_t safeBlock) {
        [[NSGameCenterManager sharedManager] submitMainAchievementWithScore:toScore completionHandler:^(NSError *error) {
            if (error)
            {
                [UIAlertView bk_showAlertViewWithTitle:NSLocalizedString(@"Problem", nil)
                                               message:NSLocalizedString(@"Could not submit your achievement.", nil)
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                     otherButtonTitles:@[ NSLocalizedString(@"Retry", nil) ] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                         if (buttonIndex == 1)
                                         {
                                             safeBlock();
                                             return;
                                         }
                                         
                                         if (completionBlock)
                                             completionBlock();
                                     }];
                
                return;
            }
            
            if (completionBlock)
                completionBlock();
        }];
    }];
}

@end
