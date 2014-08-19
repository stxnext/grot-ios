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

@interface SNGameViewController ()
{
    BOOL helpVisible;
}

@property (weak, nonatomic) IBOutlet UIView *score1x;
@property (weak, nonatomic) IBOutlet UIView *score2x;
@property (weak, nonatomic) IBOutlet UIView *score3x;
@property (weak, nonatomic) IBOutlet UIView *score4x;
@property (weak, nonatomic) IBOutlet UIImageView *helpBackground;

@property (nonatomic, strong) IBOutlet UILabel* scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel* movesLabel;
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
    
    self.scene = [[SNGameScene alloc] initWithSize:_gameView.bounds.size withDelegate:self];
    self.scene.scaleMode = SKSceneScaleModeAspectFit;
    
    _gameView.delegate = self;
    [_gameView presentScene:self.scene];
    
    for (UILabel* latoLabel in self.latoFontLabels)
    {
        latoLabel.font = [UIFont fontWithName:@"Lato-Light" size:latoLabel.font.pointSize];
    }
    
    [_gameView setNeedsLayout];
    [_gameView layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[GameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
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

- (void)addSummaryScore:(NSUInteger)value
{
    [self setSummaryScore:value + [self summaryScore]];
}

- (void)setSummaryScore:(NSUInteger)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:@"summaryScore"];
    [userDefaults synchronize];
    
//    self.summaryScoreLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (NSUInteger)summaryScore
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    if ([userDefaults integerForKey:@"summaryScore"])
    {
        return [userDefaults integerForKey:@"summaryScore"];
    }

    return 0;
}

- (void)setScore:(NSUInteger)value
{
    _score = value;
    
    [[GameKitHelper sharedGameKitHelper] submitAchievement:value];
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
}

- (void)setMoves:(NSUInteger)value
{
    _moves = value;
    
    self.movesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
}

- (void)addScore:(NSUInteger)value
{
    [self addSummaryScore:value];
    _score += value;
    
    [[GameKitHelper sharedGameKitHelper] submitAchievement:_score];
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_score];
    
    if (value > 0)
    {
        self.scoreDeltaLabel.text = [NSString stringWithFormat:@"+%lu", (unsigned long)value];
        
        self.scoreDeltaLabel.alpha = 1.0;
        [UIView animateWithDuration:0.666
                              delay:1.222
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.scoreDeltaLabel.alpha = 0.0;
                         } completion:nil];
    }
}

- (void)addMoves:(NSUInteger)value
{
    _moves += value;
    
    self.movesLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_moves];
    
    if (value > 0)
    {
        self.movesDeltaLabel.text = [NSString stringWithFormat:@"+%lu", (unsigned long)value];
        
        self.movesDeltaLabel.alpha = 1.0;
        [UIView animateWithDuration:0.666
                              delay:1.222
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.movesDeltaLabel.alpha = 0.0;
                         } completion:nil];
    }
}

#pragma mark - Menu Actions

- (IBAction)menuTapped:(id)sender
{
    if (helpVisible)
    {
        [UIView animateWithDuration:0.4 animations:^{
            self.helpContainter.alpha = 0;
        } completion:^(BOOL finished) {
            self.helpContainter.hidden = YES;
            helpVisible = NO;
        }];
    }
    else
    {
        UIActionSheet *actionSheet;
        
        if ([[GameKitHelper sharedGameKitHelper] isAuthenticated])
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Main menu" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New game", @"Help", @"Game Center", nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Main menu" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"New game", @"Help", nil];
        }
        
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            [self.scene newGameWithSize:4];
        }
            break;
            
        case 1:
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
            break;
            
        case 2:
        {
            if (actionSheet.numberOfButtons == 4) {
                [self performBlockInCurrentThread:^{
                    [[GameKitHelper sharedGameKitHelper] showLeaderboardAndAchievements:YES category:kHighScoreLeaderboardCategory];
                    [SNAnalyticsManager.sharedManager gameCenterDidShow];
                } afterDelay:1];
            }
        }
            break;
    }
}

@end
