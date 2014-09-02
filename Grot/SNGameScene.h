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

@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger summaryScore;
@property (nonatomic, assign) NSInteger moves;

- (void)addScore:(NSInteger)value;
- (void)addMoves:(NSInteger)value;
- (void)gameEndedWithScore:(NSInteger)score;

@end

@interface SNGameScene : SKScene <UIAlertViewDelegate>
{
    BOOL isAnimatingTurn;
    NSMutableArray *animationsViews;
    CGFloat cellSize;
 }

@property (nonatomic, strong) NSMutableArray *grots;
@property (nonatomic, weak) id<SNGameplayDelegate> delegate;

- (void)newGameWithSize:(int)size;
- (id)initWithSize:(CGSize)size withDelegate:(id<SNGameplayDelegate>)delegate;

@end
