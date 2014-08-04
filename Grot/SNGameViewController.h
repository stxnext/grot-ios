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

@interface SNGameViewController : UIViewController<UIActionSheetDelegate, SNGameplayDelegate>

@property (weak, nonatomic) IBOutlet SKView *helpContainter;

@end
