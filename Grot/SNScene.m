//
//  SNScene.m
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNScene.h"
#import "SNGrotView.h"
#import "SNGrotFieldModel.h"
//#import "SNMutableGrid.h"

#define BOARD_MARGIN 10
#define GROT_SPACE 2.5

@interface SNScene ()

@property (nonatomic, strong) SKLabelNode *scoreTitle;
@property (nonatomic, strong) SKLabelNode *scoreValue;
@property (nonatomic, strong) SKLabelNode *scoreBonus;

@property (nonatomic, strong) SKLabelNode *movesTitle;
@property (nonatomic, strong) SKLabelNode *movesValue;
@property (nonatomic, strong) SKLabelNode *movesBonus;

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int moves;

@end

@implementation SNScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.scoreTitle = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        self.scoreValue = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        self.scoreBonus = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        
        self.movesTitle = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        self.movesValue = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        self.movesBonus = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];

        self.scoreTitle.color = colorFromHex(0xecf0f1);
        self.scoreValue.color = colorFromHex(0xecf0f1);
        self.scoreBonus.color = colorFromHex(0xecf0f1);

        self.movesTitle.color = colorFromHex(0xecf0f1);
        self.movesValue.color = colorFromHex(0xecf0f1);
        self.movesBonus.color = colorFromHex(0xecf0f1);

        
        self.scoreTitle.fontSize = 22;
        self.scoreValue.fontSize = 22;
        self.scoreBonus.fontSize = 18;
        
        self.movesTitle.fontSize = 22;
        self.movesValue.fontSize = 22;
        self.movesBonus.fontSize = 18;

        self.scoreTitle.text = @"Score";
        self.scoreBonus.text = @"+3";
        
        self.movesTitle.text = @"Moves";
        self.movesBonus.text = @"+5";
        
        self.scoreTitle.position = CGPointMake(CGRectGetMinX(self.frame) + CGRectGetWidth(self.scoreTitle.frame)/2 + 50, CGRectGetMaxY(self.frame)-50);
        self.movesTitle.position = CGPointMake(CGRectGetMaxX(self.frame) - CGRectGetWidth(self.movesTitle.frame)/2 - 50, CGRectGetMaxY(self.frame)-50);
        
        CGPoint position = self.scoreTitle.position;
        position.y -= CGRectGetHeight(self.scoreValue.frame) + CGRectGetHeight(self.scoreTitle.frame) + 10;
        self.scoreValue.position = position;

        position = self.movesTitle.position;
        position.y -= CGRectGetHeight(self.movesValue.frame) + CGRectGetHeight(self.movesTitle.frame) + 10;
        self.movesValue.position = position;

        position = self.scoreValue.position;
        position.y -= CGRectGetHeight(self.scoreBonus.frame) + CGRectGetHeight(self.scoreValue.frame) + 10;
        self.scoreBonus.position = position;

        position = self.movesValue.position;
        position.y -= CGRectGetHeight(self.movesBonus.frame) + CGRectGetHeight(self.movesValue.frame) + 10;
        self.movesBonus.position = position;

        [self addChild:self.scoreTitle];
        [self addChild:self.scoreValue];
        [self addChild:self.scoreBonus];
        
        [self addChild:self.movesTitle];
        [self addChild:self.movesValue];
        [self addChild:self.movesBonus];

        self.score = 0;
        self.moves = 5;
        
        self.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1];
        
        isAnimatingTurn = NO;
        grotsCount = 5;
        
        self.grots = [NSMutableArray new];
        
        cellSize = (size.width - 2 * BOARD_MARGIN) / grotsCount;
        
        for (NSInteger y = 0; y < grotsCount; y++)
        {
            for (NSInteger x = 0; x < grotsCount; x++)
            {
                SNGrotView *grot = [[SNGrotView alloc] initWithSize:cellSize- 2*GROT_SPACE];
                grot.position = [self positionForX:x Y:y];
                [self addChild:grot];
                [self.grots addObject:grot];
            }
        }
    }

    return self;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
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
        
        if ([self convertPoint:location toColumn:&column row:&row])
        {
            SNGrotView *subview = (SNGrotView *)[self.grots objectAtIndex:column + row * grotsCount];
            
            if ([subview isKindOfClass:[SNGrotView class]])
            {
                SNGrotView *field = (SNGrotView *)subview;
                
                if (field.model.isAvailable)
                {
                    isAnimatingTurn = YES;
                    
                    __block void(^animateFalling)(void) = ^(void) {
                        
                        for (int i = 0;  i < self.grots.count; i++)
                        {
                            SNGrotView *grot0 = self.grots[i];
                            
                            if (grot0.model.isAvailable)
                            {
                                CGPoint currPoint = [self positionForGrot:grot0];
                                CGPoint nextPoint = [self nextEmptyPositionForCurrentPosition:currPoint];
                                
                                if (!CGPointEqualToPoint(currPoint, nextPoint))
                                {
                                    NSAssert(currPoint.x == nextPoint.x, @"BŁAD %@ ---------- %@" , NSStringFromCGPoint(currPoint) , NSStringFromCGPoint(nextPoint));

                                    SNGrotView *grot1 = [self grotForPosition:nextPoint];
                                    
                                    CGFloat animationTime = 0.1;
                                    
                                    [grot0 runAction:[SKAction group:@[[SKAction moveTo:[self positionForX:nextPoint.x Y:nextPoint.y] duration:animationTime]
                                                                       ]] completion:^{
                                    }];
                                    
                                    [self.grots exchangeObjectAtIndex:i withObjectAtIndex:[self.grots indexOfObject:grot1]];
                                }
                            }
                        }
                        
                        [self performBlockOnMainThread:^{
                            // add new grots
                            for (NSInteger y = 0; y < grotsCount; y++)
                            {
                                for (NSInteger x = 0; x < grotsCount; x++)
                                {
                                    SNGrotView *grot0 = [self grotForX:x Y:y];
                                    
                                    if (!grot0.model.isAvailable)
                                    {
                                        grot0.center = [self positionForX:x Y:y];
                                        [grot0 randomize];
                                        [grot0 setScale:0.8];
                                        [grot0 runAction:[SKAction group:@[[SKAction fadeAlphaTo:1 duration:0.1],
                                                                           [SKAction scaleTo:1 duration:0.1]
                                                                           ]] completion:^{
                                            isAnimatingTurn = NO;
                                        }];
                                    }
                                }
                            }
                        } afterDelay:0.1];
                    };
                    
                    __block void(^animateMove)(void) = ^(void) {
                        
                        SNGrotView *grot0 = (SNGrotView *)animationsViews[0];
                        
                        if (animationsViews.count > 1)
                        {
                            SNGrotView *grot1 = (SNGrotView *)animationsViews[1];
                            
                            CGFloat animationTime = (fabs(grot0.center.x - grot1.center.x) + fabs(grot0.center.y - grot1.center.y))/400;

                            [grot0 runAction:[SKAction sequence:@[[SKAction moveTo:grot1.center duration:animationTime],
                                                                            [SKAction fadeAlphaTo:0 duration:0.05]
                                                                            ]] completion:^{
                                [animationsViews removeObjectAtIndex:0];
                                animateMove();
                            }];
                        }
                        else
                        {
                            [grot0 runAction:[SKAction fadeAlphaTo:0 duration:0.25] completion:^{
                            }];
                            
                            [self performBlockInCurrentThread:^{
                                animateFalling();
                            } afterDelay:0.1];
                        }
                    };
                    
                    //start move
                    animationsViews = [NSMutableArray new];
                
                    [self nextGrot:field level:1];
                    
                    animateMove();
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
//            return CGPointMake(position.x, position.y-1);
            return position;
        }
    }
    
    return position;
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row
{
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    // Is this a valid location within the cookies layer? If yes,
    // calculate the corresponding row and column numbers.
    if (point.x >= 0 && point.x < self.size.width &&
        point.y >= 0 && point.y < 2*BOARD_MARGIN + grotsCount*cellSize)
    {
        *column = (point.x - BOARD_MARGIN)/ cellSize;
        *row = (point.y - BOARD_MARGIN) / cellSize;
        
        return YES;
    }
    else
    {
        *column = NSNotFound;  // invalid location
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
            if (newPosition.y < grotsCount - level)
                newPosition.y += level;
            else
                return nil;
            break;
            
        case SNFieldDirectionRight:
            if (newPosition.x < grotsCount - level)
                newPosition.x += level;
            else
                return nil;
            break;
    }
    
    SNGrotView *tempView = (SNGrotView *)[self.grots objectAtIndex:newPosition.x + newPosition.y * grotsCount];
    
    if (!tempView.model.isAvailable) {
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

- (void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

- (CGPoint)positionForX:(NSInteger)x Y:(NSInteger)y
{
    return CGPointMake(BOARD_MARGIN + cellSize/2 + x*cellSize, BOARD_MARGIN + cellSize/2 + y*cellSize);
}

- (CGPoint)positionForGrot:(SNGrotView *)grot
{
    NSUInteger index = [self.grots indexOfObject:grot];
    
    if (index == NSNotFound)
    {
        return  CGPointZero;
    }
    int y = (int)index / grotsCount;
    int x = (int)index - y * grotsCount;
    
    return CGPointMake(x, y);
}

- (NSInteger)indexForPositon:(CGPoint)position
{
    return position.x + position.y*grotsCount;
}

- (SNGrotView *)grotForPosition:(CGPoint)position
{
    return self.grots[(int)position.x + (int)position.y*grotsCount];
}

- (SNGrotView *)grotForX:(NSInteger)x Y:(NSInteger)y
{
    return self.grots[x + y*grotsCount];
}

#pragma mark - Labels

- (void)setScore:(int)score
{
    _score = score;
    self.scoreValue.text = [NSString stringWithFormat:@"%i", score];
}

- (void)setMoves:(int)moves
{
    _moves = moves;
    self.movesValue.text = [NSString stringWithFormat:@"%i", moves];
}

- (void)setMoveBonusText:(NSString *)text
{
    
}

- (void)setScoreBonusText:(NSString *)text
{
    
}

@end
