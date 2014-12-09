//
//  UIGameViewController.h
//  Grot
//
//  Created by Dawid Żakowski on 09/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaygroundGridViewController.h"
#import "UIFloatingResultController.h"
#import "UICounterLabel.h"

@interface UIGameViewController : UIViewController<UIPlaygroundGridViewControllerDelegate, UIFloatingResultControllerDataSource>
{
    UIPlaygroundGridViewController* _playgroundChildController;
}

@property (strong, nonatomic) IBOutlet UIView *scoreContainer;
@property (strong, nonatomic) IBOutlet UIView *movesContainer;
@property (strong, nonatomic) IBOutlet UIView *playgroundContainer;
@property (strong, nonatomic) IBOutlet UIImageView *heroIcon;

@property (nonatomic, strong) IBOutlet UICounterLabel* scoreCounter;
@property (nonatomic, strong) IBOutlet UICounterLabel* movesCounter;
@property (nonatomic, strong) IBOutlet UICounterLabel* scoreDeltaCounter;
@property (nonatomic, strong) IBOutlet UICounterLabel* movesDeltaCounter;

@property (nonatomic, strong) IBOutlet UIView* pauseButton;
@property (nonatomic, strong) IBOutlet UIView* helpButton;

@end
