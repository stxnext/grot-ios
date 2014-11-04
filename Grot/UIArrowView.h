//
//  UIArrowView.h
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNArrowField.h"

@import SpriteKit;

@class UIArrowView;

@protocol UIArrowViewDelegate <NSObject>

@optional
- (void)arrowViewTapped:(UIArrowView*)arrowView;

@end

@interface UIArrowView : SKSpriteNode

@property (nonatomic, strong) SNArrowField* model;
@property (nonatomic, weak) IBOutlet id<UIArrowViewDelegate> delegate;

@end
