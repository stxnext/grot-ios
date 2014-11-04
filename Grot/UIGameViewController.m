//
//  UIGameViewController.m
//  Grot
//
//  Created by Dawid Żakowski on 09/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIGameViewController.h"
#import "UIGameStoryboard.h"

@implementation UIGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kPlaygroundSegueIdentifier])
    {
        _playgroundChildController = segue.destinationViewController;
    }
}

@end
