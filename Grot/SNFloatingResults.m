//
//  SNFloatingResults.m
//  Grot
//
//  Created by Dawid Żakowski on 25/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNFloatingResults.h"
#import "UICounterLabel.h"

@implementation SNFloatingResultsController

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    self.menuLabel.alpha = 0.0;
//    self.scoreContainer.alpha = 0.0;
//}
//
//- (void)animate
//{
//    self.scoreCounter.maxDrawableValue = self.score;
//    self.scoreCounter.maxValue = self.highScore;
//    [self.scoreCounter setValue:0 animationSpeed:NSIntegerMax completionHandler:nil];
//    
//    self.highScoreCounter.maxDrawableValue =
//    self.highScoreCounter.maxValue = MAX(self.score, self.highScore);
//    [self.highScoreCounter setValue:self.highScore animationSpeed:NSIntegerMax completionHandler:nil];
//    
//    self.scoreContainer.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1.0);
//    
//    __weak SNFloatingResultsController* weakSelf = self;
//    
//    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.scoreContainer.alpha = 1.0;
//    } completion:^(BOOL finished) {
//        [self.scoreCounter setValue:self.score animationSpeed:0.5 completionHandler:^{
//            [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//                weakSelf.scoreContainer.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
//                weakSelf.menuLabel.alpha = 1.0;
//            } completion:nil];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////                [super animate];
//            });
//        }];
//        
//        self.scoreCounter.layout.arrowDrawnParts = SNCounterLabelArrowPartAll;
//    }];
//}

@end
