//
//  SNFloatingResults.h
//  Grot
//
//  Created by Dawid Żakowski on 25/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNFloatingMenu.h"
#import "SNCounterLabel.h"

@interface SNFloatingResultsController : SNFloatingMenuController

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray* fontLabels;
@property (nonatomic, strong) IBOutlet SNCounterLabel* highScoreCounter;
@property (nonatomic, strong) IBOutlet SNCounterLabel* scoreCounter;

@property (nonatomic, strong) IBOutlet UIView* scoreContainer;
@property (nonatomic, strong) IBOutlet UIView* buttonContainer;

@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger highScore;

@end