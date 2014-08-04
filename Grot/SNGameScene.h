//
//  SNScene.h
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SNMutableGrid;


@interface SNGameScene : SKScene
{
    BOOL isAnimatingTurn;
    BOOL isMenuVisible;
    NSMutableArray *animationsViews;
    CGFloat cellSize;
 }

@property (nonatomic, strong) NSMutableArray *grots;
- (void)newGameWithSize:(int)size;

@end
