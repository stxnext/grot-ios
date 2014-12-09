//
//  UIArrowView.h
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSArrowField.h"

@import SpriteKit;

@class UIArrowView;

@protocol UIArrowViewDelegate <NSObject>

@optional
- (void)arrowViewTouchedDown:(UIArrowView*)arrowView;
- (void)arrowViewTouchedUp:(UIArrowView*)arrowView inside:(BOOL)inside;

@end

@interface UIArrowView : SKSpriteNode

@property (nonatomic, strong) NSArrowField* model;
@property (nonatomic, weak) IBOutlet id<UIArrowViewDelegate> delegate;

@end
