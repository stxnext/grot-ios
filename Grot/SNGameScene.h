//
//  SNScene.h
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SNMutableGrid;

@protocol SNGameplayDelegate <NSObject>

@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, assign) NSUInteger moves;

- (void)addScore:(NSUInteger)value;
- (void)addMoves:(NSUInteger)value;

@end

@interface SNGameScene : SKScene
{
    BOOL isAnimatingTurn;
    BOOL isMenuVisible;
    NSMutableArray *animationsViews;
    CGFloat cellSize;
 }

@property (nonatomic, strong) NSMutableArray *grots;
@property (nonatomic, weak) id<SNGameplayDelegate> delegate;

- (id)initWithSize:(CGSize)size withDelegate:(id<SNGameplayDelegate>)delegate;

@end
