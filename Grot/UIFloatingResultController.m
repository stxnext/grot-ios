//
//  UIFloatingResultController.m
//  Grot
//
//  Created by Dawid Żakowski on 21/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFloatingResultController.h"
#import "NSHighScoreManager.h"

@implementation UIFloatingResultController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.headerLabel.text = [self.class descriptionForScore:self.dataSource.resultControllerCurrentScore];
    
    _resultDisk.highScoreCounter.maxDrawableValue = 9999;
    [_resultDisk.highScoreCounter setValue:self.dataSource.resultControllerHighScore animationSpeed:NSIntegerMax completionHandler:nil];
    
    _resultDisk.currentScoreCounter.maxDrawableValue = 9999;
    _resultDisk.currentScoreCounter.maxValue = self.dataSource.resultControllerHighScore;
    [_resultDisk.currentScoreCounter setValue:0 animationSpeed:NSIntegerMax completionHandler:nil];
    
    __weak UIResultDisk* weakDisk = _resultDisk;
    weakDisk.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);

    [_resultDisk.currentScoreCounter setValue:self.dataSource.resultControllerCurrentScore animationSpeed:0.6 completionHandler:^{
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakDisk.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
        } completion:nil];
        
        [super showGraphicInterface];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [super showButtons];
        });
    }];
    
    _resultDisk.currentScoreCounter.layout.arrowDrawnParts = SNCounterLabelArrowPartAll;
    
    [self updatePlayersHighScore];
}

- (void)updatePlayersHighScore
{
    NSInteger score = self.dataSource.resultControllerCurrentScore;
    [[NSHighScoreManager sharedManager] setHighScore:score];
}

- (BOOL)shouldShowControlsAutomatically
{
    return NO;
}

+ (NSString*)descriptionForScore:(NSUInteger)score
{
    NSString* scoreDescription = nil;
    
    if (score < 200)
        scoreDescription = @"Poor";
    else if (score < 400)
        scoreDescription = @"Fair";
    else if (score < 600)
        scoreDescription = @"Good";
    else if (score < 800)
        scoreDescription = @"Great";
    else if (score < 1000)
        scoreDescription = @"Excellent";
    else
        scoreDescription = @"Perfect!";
    
    return scoreDescription;
}

#pragma mark - Buttons data source

- (void)setupMenuButton:(UIMenuButton*)button
{
    switch ((UIFloatingResultButtonTag)button.tag)
    {
        case UIFloatingResultButtonRestartTag:
        {
            button.text = NSLocalizedString(@"Restart", nil);
            button.image = [UIImage imageNamed:@"ButtonRestart"];
            
            break;
        }
            
        case UIFloatingResultButtonGameCenterTag:
        {
            button.text = NSLocalizedString(@"Game Center", nil);
            button.image = [UIImage imageNamed:@"ButtonPad"];
            
            break;
        }
    }
}

- (NSUInteger)indexForMenuButton:(UIMenuButton*)button
{
    switch ((UIFloatingResultButtonTag)button.tag)
    {
        case UIFloatingResultButtonRestartTag: return 0;
        case UIFloatingResultButtonGameCenterTag: return 1;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    UIViewController* controller = segue.destinationViewController;
    
    if ([controller.view isKindOfClass:[UIResultDisk class]])
    {
        _resultDisk = (UIResultDisk*)controller.view;
    }
}

@end
