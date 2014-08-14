//
//  SNScene.m
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGameScene.h"
#import "SNGrotView.h"
#import "SNGrotFieldModel.h"
#import "SNMenuButton.h"
#import "SNMenuView.h"
#import "SKTEffects.h"
#import "UIBezierPath+Image.h"
#import "SNGrotHints.h"

@interface SNGameScene ()
{
    NSInteger _boardSize;
    
    int boardSideMargin;
    int bottomMargin;
    int grotSpace;
    
    int gameNumber;
    int maxScore;
    
    int newScore;
    int newMoves;
    
    SKSpriteNode *backgroundSprite;
}

@end

@implementation SNGameScene

- (id)initWithSize:(CGSize)size withDelegate:(id<SNGameplayDelegate>)delegate
{
    if (self = [super initWithSize:size])
    {
        self.delegate = delegate;
        
        boardSideMargin = INTERFACE_IS_PHONE_SMALL_SCREEN ? 20.0 : INTERFACE_IS_PAD ? 20.0 : 5.0;
        self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        
        backgroundSprite = [[SKSpriteNode alloc] initWithImageNamed:@"shadow"];
        backgroundSprite.zPosition = -1;
        [self addChild:backgroundSprite];
        
        [self newGameWithSize:[self boardSize]];
    }
    
    return self;
}

- (void)setSize:(CGSize)size
{
    [super setSize:size];
    
    int boardSideSize = (self.frame.size.width - 2*boardSideMargin);
    bottomMargin = (self.frame.size.height - boardSideSize) / 2;
    
    backgroundSprite.xScale = self.size.width / backgroundSprite.size.width;
    backgroundSprite.position = CGPointMake(self.size.width / 2.0, self.size.height - backgroundSprite.size.height / 2.0);
    
    cellSize = (self.size.width - 2 * boardSideMargin) / [self boardSize];
    
    [self revalidateGrotPositions];
}

- (void)revalidateGrotPositions
{
    for (SNGrotView* grot in self.grots)
    {
        CGFloat squareSide = cellSize - 2 * grotSpace;
        grot.size = CGSizeMake(squareSide, squareSide);
        CGPoint point = [self positionForGrot:grot];
        grot.position = [self positionForX:point.x Y:point.y];
    }
}

#pragma mark - Touches

- (void)makeMoveAtRow:(NSInteger)row column:(NSInteger)column
{
    SNGrotView *subview = (SNGrotView *)[self.grots objectAtIndex:column + row * [self boardSize]];
    
    if ([subview isKindOfClass:[SNGrotView class]])
    {
        self.delegate.moves--;
        
        SNGrotView *field = (SNGrotView *)subview;
        
        if (field.model.isAvailable)
        {
            isAnimatingTurn = YES;
            newMoves = 0;
            newScore = 0;
            //start move
            
            animationsViews = [NSMutableArray new];
            
            [self nextGrot:field level:1];
            
            // count points
            [self countScore:&newScore moves:&newMoves];
            
            // make move
            [self animateMove];
        }
    }
}

- (void)animateMove
{
    SNGrotView *grot0 = (SNGrotView *)animationsViews[0];
    
    CGPoint beginPoint = grot0.center;
    CGPoint endPoint;
    
    CGPoint p1 = [self positionForX:0 Y:0];
    CGPoint p2 = [self positionForX:0 Y:1];
    
    __block BOOL isLastMovement = animationsViews.count <= 1;
    
    if (isLastMovement)
    {
        CGPoint endPosition = [self endpointPointedByGrot:grot0];
        endPoint = [self positionForX:endPosition.x Y:endPosition.y];
    }
    else
    {
        SNGrotView *grot1 = (SNGrotView *)animationsViews[1];
        endPoint = grot1.center;
    }
    
    const CGFloat animationDivider = 300.0;
    const CGFloat movementTargetAlpha = 0.25;
    
    CGFloat minAnimationTime = (fabs(p1.x - p2.x) + fabs(p1.y - p2.y)) / animationDivider;
    CGFloat animationTime = MAX(minAnimationTime, (fabs(beginPoint.x - endPoint.x) + fabs(beginPoint.y - endPoint.y)) / animationDivider) / (INTERFACE_IS_PHONE ? 1 : 2.5);
    
    SKAction* fadeAction = [SKAction fadeAlphaTo:movementTargetAlpha duration:animationTime];
    SKAction* moveAction = [SKAction moveTo:endPoint duration:animationTime];
    SKAction* fadeOutAction = [SKAction fadeOutWithDuration:animationTime / 3.0 / 2.0];
    
    fadeAction.timingMode = SKActionTimingEaseIn;
    moveAction.timingMode = SKActionTimingEaseOut;
    fadeOutAction.timingMode = SKActionTimingEaseOut;
    
    grot0.zPosition = 20;
    [grot0 runAction:[SKAction sequence:@[ [SKAction group:@[moveAction, fadeAction]], fadeOutAction ]] completion:^{
        
        if (isLastMovement)
        {
            [self performBlockOnMainThread:^{
                [self animateFalling];
            } afterDelay:0.1];
        }
        else
        {
            grot0.alpha = 0.0;
            [animationsViews removeObjectAtIndex:0];
            [self animateMove];
        }
    }];
}

- (void)animateFalling
{
    CGFloat fallAnimationTime = 0.5 ;
    BOOL isFalling = NO;
    
    for (int i = 0;  i < self.grots.count; i++)
    {
        SNGrotView *grot0 = self.grots[i];
        
        if (grot0.model.isAvailable)
        {
            CGPoint currPoint = [self positionForGrot:grot0];
            CGPoint nextPoint = [self nextEmptyPositionForCurrentPosition:currPoint];
            
            if (!CGPointEqualToPoint(currPoint, nextPoint))
            {
                SNGrotView *grot1 = [self grotForPosition:nextPoint];
                
                SKTMoveEffect *moveEffect = [SKTMoveEffect effectWithNode:grot0
                                                                 duration:fallAnimationTime
                                                            startPosition:grot0.position
                                                              endPosition:[self positionForX:nextPoint.x Y:nextPoint.y]];
                
                moveEffect.timingFunction = SKTTimingFunctionBounceEaseOut;
                
                SKAction *moveAction = [SKAction actionWithEffect:moveEffect];
                
                
                [grot0 runAction:moveAction];
                
                
                [self.grots exchangeObjectAtIndex:i withObjectAtIndex:[self.grots indexOfObject:grot1]];
                
                isFalling = YES;
            }
        }
    }
    
    [self performBlockOnMainThread:^{
        // add new grots
        __block int animationsCount = 0;
        
        for (NSInteger y = 0; y < [self boardSize]; y++)
        {
            for (NSInteger x = 0; x < [self boardSize]; x++)
            {
                SNGrotView *grot0 = [self grotForX:x Y:y];
                
                if (!grot0.model.isAvailable)
                {
                    animationsCount++;
                    grot0.center = [self positionForX:x Y:y];
                    [grot0 randomize];
                    
                    [grot0 setScale:0.8];
                    
                    [grot0 runAction:[SKAction group:@[[SKAction fadeAlphaTo:1 duration:0.1],
                                                       [SKAction scaleTo:1 duration:0.1]
                                                       ]] completion:^{
                        
                        if (--animationsCount == 0)
                        {
                            [self.delegate addMoves:newMoves];
                            [self.delegate addScore:newScore];
                            
                            isAnimatingTurn = NO;
                            
                            if (self.delegate.moves == 0)
                            {
                                [self endGame];
                            }
                        }
                    }];
                }
            }
        }
    } afterDelay:isFalling ? fallAnimationTime : 0.1];
}


- (void)countScore:(int *)newScore moves:(int *)newMoves
{
    NSMutableDictionary *collumnDictX = [NSMutableDictionary new];
    NSMutableDictionary *collumnDictY = [NSMutableDictionary new];
    
    for (SNGrotView *grot in animationsViews)
    {
        *newScore += grot.model.value;
        CGPoint position = [self positionForGrot:grot];
        collumnDictX[[NSNumber numberWithInt:position.x]] = [collumnDictX[[NSNumber numberWithInt:position.x]] intValue] > 0 ?
        [NSNumber numberWithInt:[collumnDictX[[NSNumber numberWithInt:position.x]] intValue] + 1] : @1;
        
        collumnDictY[[NSNumber numberWithInt:position.y]] = [collumnDictY[[NSNumber numberWithInt:position.y]] intValue] > 0 ?
        [NSNumber numberWithInt:[collumnDictY[[NSNumber numberWithInt:position.y]] intValue] + 1] : @1;
        
        grot.zPosition = 10;
    }
    
    int emptyRows = 0;
    int emptyColumns = 0;
    
    for (NSNumber *key in collumnDictX)
    {
        if ([[collumnDictX objectForKey:key] intValue] == [self boardSize])
        {
            emptyColumns++;
        }
    }
    
    for (NSNumber *key in collumnDictY)
    {
        if ([[collumnDictY objectForKey:key] intValue] == [self boardSize])
        {
            emptyRows++;
        }
    }
    
    *newScore += (emptyColumns + emptyRows) * [self boardSize] * 10;
    
    int threshold = floor((*newScore + self.delegate.score) / (5 * [self boardSize] * [self boardSize])) + [self boardSize] - 1;
    
    if (threshold <= animationsViews.count)
    {
        *newMoves = (int)animationsViews.count - threshold;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (isAnimatingTurn)
    {
        return;
    }
    
    if (touch.tapCount == 1)
    {
        NSInteger column, row;
        CGPoint location = [touch locationInNode:self];
        
        if ([self convertPoint:location toColumn:&column row:&row] && self.delegate.moves > 0 && !isMenuVisible)
        {
            [self makeMoveAtRow:row column:column];
        }
        else
        {
            CGPoint touchLocation = [touch locationInNode:self];
            SKNode *touchedNode = [self nodeAtPoint:touchLocation];
            
            if ([touchedNode.name isEqualToString:@"menuButton"])
            {
                [self toggleMenu];
            }
            else
            {
                if ([touchedNode.name isEqualToString:@"level1Button"])
                {
                    [self toggleMenu];
                    [self newGameWithSize:3];
                }
                else if ([touchedNode.name isEqualToString:@"level2Button"])
                {
                    [self toggleMenu];
                    [self newGameWithSize:4];
                }
                else if ([touchedNode.name isEqualToString:@"level3Button"])
                {
                    [self toggleMenu];
                    [self newGameWithSize:5];
                }
            }
        }
    }
}

- (CGPoint)nextEmptyPositionForCurrentPosition:(CGPoint)position
{
    if (position.y > 0)
    {
        SNGrotView *grot = [self grotForPosition:CGPointMake(position.x, position.y-1)];
        
        if (!grot.model.isAvailable)
        {
            return [self nextEmptyPositionForCurrentPosition:CGPointMake(position.x, position.y-1)];
        }
        else
        {
            return position;
        }
    }
    
    return position;
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row
{
    if (point.x >= boardSideMargin &&
        point.x < self.size.width - boardSideMargin &&
        point.y >= bottomMargin &&
        point.y < bottomMargin + boardSideMargin + [self boardSize]*cellSize)
    {
        *column = (point.x - boardSideMargin)/ cellSize;
        *row = (point.y - bottomMargin - boardSideMargin) / cellSize;
        
        return YES;
    }
    else
    {
        *column = NSNotFound;
        *row = NSNotFound;
        
        return NO;
    }
}

- (SNGrotView *)nextGrot:(SNGrotView *)currentGrot level:(int)level
{
    if (currentGrot && ![animationsViews containsObject:currentGrot])
    {
        [animationsViews addObject:currentGrot];
    }
    
    currentGrot.model.isAvailable = NO;
    
    CGPoint newPosition = [self positionForGrot:currentGrot];
    
    switch (currentGrot.model.direction)
    {
        case SNFieldDirectionUp:
            if (newPosition.y > level -1)
                newPosition.y -= level;
            else
                return nil;
            break;
            
        case SNFieldDirectionLeft:
            if (newPosition.x > level - 1)
                newPosition.x -= level;
            else
                return nil;
            break;
            
        case SNFieldDirectionDown:
            if (newPosition.y < [self boardSize] - level)
                newPosition.y += level;
            else
                return nil;
            break;
            
        case SNFieldDirectionRight:
            if (newPosition.x < [self boardSize] - level)
                newPosition.x += level;
            else
                return nil;
            break;
    }
    
    SNGrotView *tempView = (SNGrotView *)[self.grots objectAtIndex:newPosition.x + newPosition.y * [self boardSize]];
    
    if (!tempView.model.isAvailable)
    {
        SNGrotView *resultView = [self nextGrot:currentGrot level:++level];
        
        return resultView;
    }
    else
    {
        SNGrotView *resultView = [self nextGrot:tempView level:1];
        
        return resultView;
    }
    
    return nil;
}

#pragma mark - Calculations

- (BOOL)isPositionOutOfBounds:(CGPoint)position
{
    return position.x < 0 || position.y < 0 || position.x >= self.boardSize || position.y >= self.boardSize;
}

- (CGPoint)endpointPointedByGrot:(SNGrotView*)grot
{
    for (CGPoint nextPosition, position = nextPosition = [self positionForGrot:grot]; true; position = nextPosition)
    {
        switch (grot.model.direction)
        {
            case SNFieldDirectionUp: nextPosition.y -= 1; break;
            case SNFieldDirectionLeft: nextPosition.x -= 1; break;
            case SNFieldDirectionDown: nextPosition.y += 1; break;
            case SNFieldDirectionRight: nextPosition.x += 1; break;
        }
        
        if ([self grotForPosition:nextPosition].alpha == 1.0)
        {
            return nextPosition;
        }
        
        if ([self isPositionOutOfBounds:nextPosition])
        {
            return position;
        }
    }
}

- (CGPoint)positionForX:(NSInteger)x Y:(NSInteger)y
{
    return CGPointMake(boardSideMargin + cellSize/2 + x*cellSize, bottomMargin + cellSize/2 + y*cellSize);
}

- (CGPoint)positionForIndex:(int)index
{
    int y = (int)index / [self boardSize];
    int x = (int)index - y*[self boardSize];
    
    return CGPointMake(y, x);
}

- (CGPoint)positionForGrot:(SNGrotView *)grot
{
    NSUInteger index = [self.grots indexOfObject:grot];
    
    if (index == NSNotFound)
    {
        return  CGPointZero;
    }
    
    int y = (int)index / [self boardSize];
    int x = (int)index - y*[self boardSize];
    
    return CGPointMake(x, y);
}

- (NSInteger)indexForPositon:(CGPoint)position
{
    if ([self isPositionOutOfBounds:position])
    {
        return -1;
    }
    else
    {
        return position.x + position.y*[self boardSize];
    }
}

- (SNGrotView *)grotForPosition:(CGPoint)position
{
    NSInteger index = [self indexForPositon:position];
    
    return index >= 0 && self.grots.count > index ? self.grots[index] : nil;
}

- (SNGrotView *)grotForX:(NSInteger)x Y:(NSInteger)y
{
    return [self grotForPosition:CGPointMake(x, y)];
}

#pragma mark - Game action

- (void)endGame
{
    int64_t score = self.delegate.score;
    int64_t summaryScore = self.delegate.summaryScore;
    
    [[GameKitHelper sharedGameKitHelper] submitScore:(int64_t)score category:kHighScoreLeaderboardCategory];
//    [[GameKitHelper sharedGameKitHelper] submitScore:(int64_t)summaryScore category:kSummaryHighScoreLeaderboardCategory];
    
    for (SNGrotView *grot in self.grots)
    {
        [grot runAction:[SKAction sequence:@[[SKAction waitForDuration:0.3],
                                             [SKAction fadeAlphaTo:0.2 duration:0.4]]]];
    }
    
    if ((unsigned long)self.delegate.score > maxScore)
    {
        maxScore = (unsigned long)self.delegate.score;
        NSLog(@"%i \t\t%i" ,gameNumber, maxScore);
    }
    
    [self performBlockOnMainThread:^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Game over"
                                                            message:[NSString stringWithFormat:@"You've scored %lu points. Try again!", (unsigned long)self.delegate.score]
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"New game", nil];
        
        [alertView show];
    } afterDelay:0.8];
}

- (void)toggleMenu
{
    isMenuVisible = !isMenuVisible;
    
    for (SNGrotView *grot in self.grots)
    {
        CGFloat alpha = 1;
        
        if (self.delegate.moves == 0)
        {
            alpha = grot.alpha;
        }
        else if (isMenuVisible)
        {
            alpha = 0.1;
        }
        
        [grot runAction:[SKAction sequence:@[[SKAction waitForDuration:isMenuVisible ? 0.3 : 0],
                                             [SKAction group:@[[SKAction scaleTo:isMenuVisible ? 0.8 : 1 duration:0.2],
                                                               [SKAction fadeAlphaTo:alpha duration:0.2]]]
                                             ]]];
    }
}

- (void)newGameWithSize:(int)size
{
    gameNumber++;
    [self setBoardSize:size];
    
    grotSpace = (INTERFACE_IS_PAD ? 10.0 : 5.0) - (size - 2);
    
    self.delegate.score = 0;
    self.delegate.moves = 5;
    
    for (SNGrotView *grot in self.grots)
    {
        [grot runAction:[SKAction fadeAlphaTo:0 duration:0.2] completion:^{
            [grot removeFromParent];
        }];
    }
    
    isAnimatingTurn = NO;
    
    [self performBlockOnMainThread:^{
        self.grots = [NSMutableArray new];
        
        for (NSInteger y = 0; y < [self boardSize]; y++)
        {
            for (NSInteger x = 0; x < [self boardSize]; x++)
            {
                SNGrotView *grot = [[SNGrotView alloc] initWithSize:cellSize - 2*grotSpace];
                grot.position = [self positionForX:x Y:y];
                grot.alpha = 0;
                grot.zPosition = -1;
                
                [self addChild:grot];
                [self.grots addObject:grot];
                
                [grot runAction:[SKAction fadeAlphaTo:1 duration:0.2]];
            }
        }
    } afterDelay:0.2];
}

#pragma mark - BoardSize

- (int)boardSize
{
    
    if (_boardSize == 0)
    {
        _boardSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"boardSize"] ? : 4;
    }
    
    return (int)_boardSize;
}

- (void)setBoardSize:(int)boardSize
{
    [[NSUserDefaults standardUserDefaults] setInteger:boardSize forKey:@"boardSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _boardSize = 0;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self newGameWithSize:[self boardSize]];
}

@end
