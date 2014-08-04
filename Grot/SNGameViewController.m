//
//  SNGameViewController.m
//  Grot
//
//  Created by Dawid Żakowski on 31/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGameViewController.h"
#import <SpriteKit/SpriteKit.h>

@interface SNGameViewController ()
{
    NSUInteger _score;
    NSUInteger _moves;
}

@property (nonatomic, strong) IBOutlet UILabel* scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel* movesLabel;
@property (nonatomic, strong) IBOutlet UILabel* scoreDeltaLabel;
@property (nonatomic, strong) IBOutlet UILabel* movesDeltaLabel;

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray* passThroughViews;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray* latoFontLabels;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet SKView* gameView;
@property (nonatomic, strong) SNGameScene *scene;
@end

@implementation SNGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SNGameScene *scene = [[SNGameScene alloc] initWithSize:_gameView.bounds.size withDelegate:self];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [_gameView presentScene:scene];
    
    for (UILabel* latoLabel in self.latoFontLabels)
        latoLabel.font = [UIFont fontWithName:@"Lato-Light" size:latoLabel.font.pointSize];
}

+ (UIImage *) setImage:(UIImage *)image withAlpha:(CGFloat)alpha{
    
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

- (void)setScore:(NSUInteger)value
{
    _score = value;
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (void)setMoves:(NSUInteger)value
{
    _moves = value;
    
    self.movesLabel.text = [NSString stringWithFormat:@"%d", value];
}

- (void)addScore:(NSUInteger)value
{
    _score += value;
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", _score];
    
    if (value > 0)
    {
        self.scoreDeltaLabel.text = [NSString stringWithFormat:@"+%d", value];
        
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
    
    self.movesLabel.text = [NSString stringWithFormat:@"%d", _moves];
    
    if (value > 0)
    {
        self.movesDeltaLabel.text = [NSString stringWithFormat:@"+%d", value];
        
        self.movesDeltaLabel.alpha = 1.0;
        [UIView animateWithDuration:0.666
                              delay:1.222
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.movesDeltaLabel.alpha = 0.0;
                         } completion:nil];
    }
}

@end
