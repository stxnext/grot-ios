//
//  UIGameViewController.h
//  Grot
//
//  Created by Dawid Żakowski on 09/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaygroundGridViewController.h"

@interface UIGameViewController : UIViewController
{
    UIPlaygroundGridViewController* _playgroundChildController;
}

@property (nonatomic, strong) IBOutlet UILabel* scoreCounter;
@property (nonatomic, strong) IBOutlet UILabel* movesCounter;

@end
