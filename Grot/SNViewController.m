//
//  SNViewController.m
//  Grot
//
//  Created by Dawid Żakowski on 16/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "SNGameScene.h"

@implementation SNViewController

#define MARGIN 10
#define SPACE 2.5

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SKView *skView = (SKView *)self.view;
    
    // Create and configure the scene.
    SKScene *scene = [SNGameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
