//
//  UIPlaygroundGridViewController.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIPlaygroundGridView.h"

@interface UIPlaygroundGridViewController : UIViewController<UIPlaygroundGridViewDataSource>

@property (nonatomic, strong) SNGameState* gameState;
@property (nonatomic, strong) IBOutlet UIPlaygroundGridView* gridView;

@end

