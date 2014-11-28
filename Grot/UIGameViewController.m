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

const CGSize kDefaultGridSize = (CGSize){ 4, 4 };
const NSUInteger kDefaultInitialMoves = 5;

@implementation UIGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scoreCounter.maxDrawableValue = self.movesCounter.maxDrawableValue = 9999;
    
    _playgroundChildController.view.backgroundColor = self.view.backgroundColor;
    _playgroundChildController.delegate = self;
    
    // Rotations observer
    if (INTERFACE_IS_PHONE && iOS8_PLUS)
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

- (void)interfaceOrientationChanged:(NSNotification*)notification
{
    UIDevice* device = notification.object;
    UIDeviceOrientation orientation = device.orientation;
    
    if (orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationFaceUp)
        return;
    
    NSArray* rotableViews = @[ self.scoreContainer, self.movesContainer, self.pauseButton, self.helpButton, self.heroIcon ];
    CGFloat angle = 0.0;

    switch (orientation)
    {
        case UIDeviceOrientationPortrait: angle = 0.0; break;
        case UIDeviceOrientationPortraitUpsideDown: return;
        case UIDeviceOrientationLandscapeRight: angle = -M_PI_2; break;
        case UIDeviceOrientationLandscapeLeft: angle = M_PI_2; break;
    }

    [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
        for (UIView* view in rotableViews)
            view.transform = CGAffineTransformMakeRotation(angle);
    }];
}

- (void)restartGame
{
    [_playgroundChildController restartGameWithGridSize:kDefaultGridSize initialMoves:kDefaultInitialMoves];
}

- (void)gameDidEndWithScore:(NSInteger)score
{
    [self submitGameCenterLeaderboardScore:score withCompletionHandler:nil];
    
    [self performSegueWithIdentifier:kMenuResultsSegueIdentifier sender:self];
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

- (void)playgroundController:(UIPlaygroundGridViewController*)controller didChangeFromResults:(SNGameResults*)fromResults toResults:(SNGameResults*)toResults
{
    NSInteger scoreDelta = toResults.score - fromResults.score;
    NSInteger movesDelta = toResults.moves - fromResults.moves;
    
    CGFloat scoreCounterSpeed = scoreDelta == 0 ? CGFLOAT_MAX : 1.0;
    CGFloat movesCounterSpeed = movesDelta == 0 ? CGFLOAT_MAX : 1.0;
    
    NSInteger visibleMoves = MAX(0, toResults.moves);
    
    [self.scoreCounter setValue:toResults.score animationSpeed:scoreCounterSpeed completionHandler:nil];
    [self.movesCounter setValue:visibleMoves animationSpeed:movesCounterSpeed completionHandler:nil];
    
    if (visibleMoves <= 0)
    {
        [self gameDidEndWithScore:toResults.score];
    }
    
    [self submitGameCenterAchievementFromScore:fromResults.score toScore:toResults.score withCompletionHandler:nil];
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
    [[NSGameCenterManager sharedManager] authenticatePlayerWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            return;
        }
        
        [self.class performBlock:^(dispatch_block_t safeBlock) {
            [[NSGameCenterManager sharedManager] submitMainLeaderboardWithScore:score completionHandler:^(NSError *error) {
                if (error)
                {
                    [UIAlertView bk_showAlertViewWithTitle:@"Problem" message:@"Could not submit your score." cancelButtonTitle:@"Cancel" otherButtonTitles:@[ @"Retry" ] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
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
    
    if (shouldSubmit)
    {
        [[NSGameCenterManager sharedManager] authenticatePlayerWithCompletionHandler:^(NSError *error) {
            if (error)
            {
                return;
            }
            
            [self.class performBlock:^(dispatch_block_t safeBlock) {
                [[NSGameCenterManager sharedManager] submitMainAchievementWithScore:toScore completionHandler:^(NSError *error) {
                    if (error)
                    {
                        [UIAlertView bk_showAlertViewWithTitle:@"Problem" message:@"Could not submit your achievement." cancelButtonTitle:@"Cancel" otherButtonTitles:@[ @"Retry" ] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
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
        }];
    }
    else
    {
        if (completionBlock)
            completionBlock();
    }
}

@end
