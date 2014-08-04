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

@interface SNGameViewController ()

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;
@property (nonatomic, strong) IBOutlet SKView* gameView;

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
    
    SKScene *scene = [SNGameScene sceneWithSize:_gameView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [_gameView presentScene:scene];
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

@end
