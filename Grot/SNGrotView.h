//
//  SNGrotFieldView.h
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@class SNGrotFieldModel;

@interface SNGrotView : SKSpriteNode

@property (nonatomic, strong) SNGrotFieldModel *model;
@property (nonatomic) CGPoint center;

- (id)initWithSize:(CGFloat)size;
- (void)randomize;

@end