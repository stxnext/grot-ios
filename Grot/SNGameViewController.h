//
//  SNGameViewController.h
//  Grot
//
//  Created by Dawid Żakowski on 31/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "SNGameScene.h"
#import "SKObservableView.h"

@interface SNGameViewController : GAITrackedViewController<UIActionSheetDelegate, SNGameplayDelegate, SKObservableViewDelegate>

@property (weak, nonatomic) IBOutlet SKView *helpContainter;

@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, assign) NSUInteger moves;

@end
