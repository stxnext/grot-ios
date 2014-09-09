//
//  SNGameViewController.m
//  Grot
//
//  Created by Dawid Żakowski on 31/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGameViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "SNGameScene.h"
#import "SNGrotFieldModel.h"
#import "GPUImage.h"
#import "SNFloatingMenu.h"
#import "SNFloatingResults.h"

@interface SNGameViewController ()
{
    BOOL helpVisible;
}

@property (weak, nonatomic) IBOutlet UIView *score1x;
@property (weak, nonatomic) IBOutlet UIView *score2x;
@property (weak, nonatomic) IBOutlet UIView *score3x;
@property (weak, nonatomic) IBOutlet UIView *score4x;
@property (weak, nonatomic) IBOutlet UIImageView *helpBackground;

@property (nonatomic, strong) IBOutlet SNCounterLabel* scoreLabel;
@property (nonatomic, strong) IBOutlet SNCounterLabel* movesLabel;
@property (nonatomic, strong) IBOutlet UILabel* scoreDeltaLabel;
@property (nonatomic, strong) IBOutlet UILabel* movesDeltaLabel;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray* passThroughViews;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray* latoFontLabels;
@property (nonatomic, strong) IBOutlet SKObservableView* gameView;
@property (nonatomic, strong) SNGameScene *scene;
@end

@implementation SNGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scene = [[SNGameScene alloc] initWithSize:_gameView.bounds.size
                                      withDelegate:self];
    self.scene.scaleMode = SKSceneScaleModeAspectFit;
    
    _gameView.delegate = self;
    [_gameView presentScene:self.scene];
    
    for (UILabel* latoLabel in self.latoFontLabels)
    {
        latoLabel.font = [UIFont fontWithName:@"Lato-Light"
                                         size:latoLabel.font.pointSize];
    }
    
    self.scoreLabel.maxDrawableValue = 9999;
    self.movesLabel.maxDrawableValue = 99;
    
    [_gameView setNeedsLayout];
    [_gameView layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
    
    self.scoreLabel.alignCenter = YES;
    self.movesLabel.alignCenter = YES;
}

- (void)viewDidLayoutSubviews:(UIView*)view
{
    self.scene.size = _gameView.bounds.size;
}

+ (UIImage *)setImage:(UIImage *)image withAlpha:(CGFloat)alpha{
    
    // Create a pixel buffer in an easy to use format
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    UInt8 * m_PixelBuf = malloc(sizeof(UInt8) * height * width * 4);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(m_PixelBuf, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    //alter the alpha
    int length = height * width * 4;
    
    for (int i=0; i<length; i+=4)
    {
        m_PixelBuf[i+3] =  255*alpha;
    }
    
    //create a new image
    CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf, width, height,
                                             bitsPerComponent, bytesPerRow, colorSpace,
                                             kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newImgRef = CGBitmapContextCreateImage(ctx);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
    free(m_PixelBuf);
    
    UIImage *finalImage = [UIImage imageWithCGImage:newImgRef];
    CGImageRelease(newImgRef);
    
    return finalImage;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return UIInterfaceOrientationMaskLandscape;
    }
}

#pragma mark Gameplay delegate

- (void)addCash:(NSUInteger)value
{
    [self setCash:value + [self cash]];
}

- (void)setCash:(NSUInteger)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:@"cash"];
    [userDefaults synchronize];
    
//    self.cashLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (NSUInteger)cash
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults integerForKey:@"cash"])
    {
        return [userDefaults integerForKey:@"cash"];
    }
    
    return 0;
}

- (void)addSummaryScore:(NSInteger)value
{
    [self setSummaryScore:value + [self summaryScore]];
}

- (void)setSummaryScore:(NSInteger)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:@"summaryScore"];
    [userDefaults synchronize];
    
//    self.summaryScoreLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (NSInteger)summaryScore
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    if ([userDefaults integerForKey:@"summaryScore"])
    {
        return [userDefaults integerForKey:@"summaryScore"];
    }

    return 0;
}

- (void)setScore:(NSInteger)value
{
    _score = value;
    
    [[GameKitHelper sharedGameKitHelper] submitAchievement:value];
    
    [self.scoreLabel setValue:value animationSpeed:1.5 completionHandler:nil];
}

- (void)setMoves:(NSInteger)value
{
    _moves = value;
    
    [self.movesLabel setValue:value animationSpeed:1.5 completionHandler:nil];
}

- (void)addScore:(NSInteger)value
{
    [self addSummaryScore:value];
    _score += value;
    
    [[GameKitHelper sharedGameKitHelper] submitAchievement:_score];
    
    if (value != 0)
    {
        [self.scoreLabel setValue:_score animationSpeed:1.5 completionHandler:nil];
        
        self.scoreDeltaLabel.text = [NSString stringWithFormat:@"%@%d", value >= 0 ? @"+" : @"", value];
        
        self.scoreDeltaLabel.alpha = 1.0;
        [UIView animateWithDuration:0.666
                              delay:1.222
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.scoreDeltaLabel.alpha = 0.0;
                         } completion:nil];
    }
}

- (void)addMoves:(NSInteger)value
{
    _moves += value;
    
    if (value != 0)
    {
        [self.movesLabel setValue:_moves animationSpeed:1.5 completionHandler:nil];
        
        self.movesDeltaLabel.text = [NSString stringWithFormat:@"%@%d", value >= 0 ? @"+" : @"", value];
        
        self.movesDeltaLabel.alpha = 1.0;
        [UIView animateWithDuration:0.666
                              delay:1.222
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.movesDeltaLabel.alpha = 0.0;
                         } completion:nil];
    }
}

#pragma mark - Outcoming segues

- (void)toggleHelp:(BOOL)show
{
    if (show && !helpVisible)
    {
        UIGraphicsBeginImageContext(self.gameView.bounds.size);
        [self.gameView drawViewHierarchyInRect:self.gameView.bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = 6;
        blurFilter.saturation = 0.5;
        
        image = [blurFilter imageByFilteringImage:image];
        
        self.helpBackground.image = image;
        
        self.score1x.backgroundColor = [SNGrotFieldModel colors][kColor1];
        self.score1x.layer.borderColor = [UIColor whiteColor].CGColor;
        self.score1x.layer.borderWidth = INTERFACE_IS_PHONE ? 1 : 2;
        self.score1x.layer.cornerRadius = self.score1x.frame.size.width/2;
        
        self.score2x.backgroundColor = [SNGrotFieldModel colors][kColor2];
        self.score2x.layer.borderColor = [UIColor whiteColor].CGColor;
        self.score2x.layer.borderWidth = INTERFACE_IS_PHONE ? 1 : 2;
        self.score2x.layer.cornerRadius = self.score2x.frame.size.width/2;
        
        self.score3x.backgroundColor = [SNGrotFieldModel colors][kColor3];
        self.score3x.layer.borderColor = [UIColor whiteColor].CGColor;
        self.score3x.layer.borderWidth = INTERFACE_IS_PHONE ? 1 : 2;
        self.score3x.layer.cornerRadius = self.score3x.frame.size.width/2;
        
        self.score4x.backgroundColor = [SNGrotFieldModel colors][kColor4];
        self.score4x.layer.borderColor = [UIColor whiteColor].CGColor;
        self.score4x.layer.borderWidth = INTERFACE_IS_PHONE ? 1 : 2;
        self.score4x.layer.cornerRadius = self.score4x.frame.size.width/2;
        
        helpVisible = YES;
        self.helpContainter.alpha = 0;
        self.helpContainter.hidden = NO;
        
        [UIView animateWithDuration:0.4 animations:^{
            self.helpContainter.alpha = 1;
        } completion:^(BOOL finished) {
            [SNAnalyticsManager.sharedManager helpDidShow];
        }];
    }
    else if (!show && helpVisible)
    {
        [UIView animateWithDuration:0.4 animations:^{
            self.helpContainter.alpha = 0;
        } completion:^(BOOL finished) {
            self.helpContainter.hidden = YES;
            helpVisible = NO;
        }];
    }
}

- (void)showGameCenter
{
//    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
//    return;
    
    [[GameKitHelper sharedGameKitHelper] showLeaderboardAndAchievements:YES category:kHighScoreLeaderboardCategory];
    [SNAnalyticsManager.sharedManager leaderboardDidShow];
}

#pragma mark - Menu Actions

- (IBAction)menuTapped:(id)sender
{
    if (helpVisible)
    {
        [self toggleHelp:NO];
    }
    else
    {
        [SNFloatingMenuController showMenuWithDecorator:^(SNFloatingMenuController *menu) {
            __weak SNFloatingMenuController* weakMenu = menu;
            
            menu.menuSelectionBlock = ^(SNFloatingMenuOption option) {
                switch (option)
                {
                    case SNFloatingMenuOptionResume:
                    {
                        [weakMenu dismissWithCompletionHandler:^{
                            
                        }];
                        
                        break;
                    }
                        
                    case SNFloatingMenuOptionRestart:
                    {
                        [weakMenu dismissWithCompletionHandler:^{
                            [self.scene newGameWithSize:4];
                        }];
                        
                        break;
                    }
                    
                    case SNFloatingMenuOptionGameCenter:
                    {
                        [self showGameCenter];
                        break;
                    }
                    
                    case SNFloatingMenuOptionInstructions:
                    {
                        [weakMenu dismissWithCompletionHandler:^{
                            [self toggleHelp:YES];
                        }];
                        
                        break;
                    }
                }
            };
        }];
    }
}

#pragma mark - Highscore

- (void)gameEndedWithScore:(NSInteger)score
{
    [SNFloatingResultsController showMenuWithDecorator:^(SNFloatingMenuController *menu) {
        SNFloatingResultsController* results = (SNFloatingResultsController*)menu;
        results.score = self.score;
        results.highScore = SNHighScoreManager.sharedManager.highScore;
        
        [SNHighScoreManager.sharedManager submitHighScore:score];
        
        NSString* scoreDescription;
        
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
        
        results.menuLabel.text = scoreDescription;
        
        __weak SNFloatingResultsController* weakResults = results;
        
        results.menuSelectionBlock = ^(SNFloatingMenuOption option) {
            switch (option)
            {
                case SNFloatingMenuOptionRestart:
                {
                    [weakResults dismissWithCompletionHandler:^{
                        [self.scene newGameWithSize:4];
                    }];
                    
                    break;
                }
                
                case SNFloatingMenuOptionGameCenter:
                {
                    [self showGameCenter];
                    break;
                }
            }
        };
    }];
}

@end
