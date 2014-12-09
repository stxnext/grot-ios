//
//  UIResultDisk.h
//  Grot
//
//  Created by Dawid Żakowski on 26/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICounterLabel.h"

@interface UIResultDisk : UIView

@property (nonatomic, strong) IBOutlet UICounterLabel* highScoreCounter;
@property (nonatomic, strong) IBOutlet UICounterLabel* currentScoreCounter;

@end
