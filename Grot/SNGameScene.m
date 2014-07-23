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

#define BOARD_MARGIN 5
#define BOARD_BOTTOM_MARGIN 60
#define GROT_SPACE 5

@interface SNGameScene ()

@property (nonatomic, strong) SKLabelNode *scoreTitle;
@property (nonatomic, strong) SKLabelNode *scoreValue;
@property (nonatomic, strong) SKLabelNode *scoreBonus;

@property (nonatomic, strong) SKLabelNode *movesTitle;
@property (nonatomic, strong) SKLabelNode *movesValue;
@property (nonatomic, strong) SKLabelNode *movesBonus;

@property (nonatomic, strong) SKSpriteNode *helpView;
@property (nonatomic, strong) SKSpriteNode *bottomBar;

@property (nonatomic, strong) SNMenuButton *menuButton;
@property (nonatomic, strong) SNMenuView *menuView;

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int moves;

@end

@implementation SNGameScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.bottomBar = [[SKSpriteNode alloc] initWithImageNamed:@"menu"];
        self.scoreTitle = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        self.scoreValue = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        self.scoreBonus = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        
        self.movesTitle = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        self.movesValue = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];
        self.movesBonus = [SKLabelNode labelNodeWithFontNamed:@"Courier New"];

        self.menuView = [SNMenuView new];
        self.menuButton = [[SNMenuButton alloc] initWithSize:50 angle:M_PI/4];
        
        
        self.scoreTitle.color = colorFromHex(0xecf0f1);
        self.scoreValue.color = colorFromHex(0xecf0f1);
        self.scoreBonus.color = colorFromHex(0xecf0f1);

        self.movesTitle.color = colorFromHex(0xecf0f1);
        self.movesValue.color = colorFromHex(0xecf0f1);
        self.movesBonus.color = colorFromHex(0xecf0f1);
        
        
        self.scoreTitle.fontSize = 22;
        self.scoreValue.fontSize = 22;
        self.scoreBonus.fontSize = 14;
        
        self.movesTitle.fontSize = 22;
        self.movesValue.fontSize = 22;
        self.movesBonus.fontSize = 14;

        
        self.scoreTitle.text = @"Score";
        self.scoreBonus.text = @"1";
        self.scoreBonus.text = @"";
        
        self.movesTitle.text = @"Moves";
        self.movesBonus.text = @"1";
        self.movesBonus.text = @"";
        
        
        self.scoreTitle.position = CGPointMake(CGRectGetMinX(self.frame) + CGRectGetWidth(self.scoreTitle.frame)/2 + 50, CGRectGetMaxY(self.frame) - 30);
        self.movesTitle.position = CGPointMake(CGRectGetMaxX(self.frame) - CGRectGetWidth(self.movesTitle.frame)/2 - 50, CGRectGetMaxY(self.frame) - 30);
        
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
        
        self.bottomBar.position = CGPointMake(CGRectGetWidth(self.bottomBar.frame)/2, CGRectGetHeight(self.bottomBar.frame)/2);
        
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
        boardSize = 4;
        
        self.grots = [NSMutableArray new];
        
        cellSize = (size.width - 2 * BOARD_MARGIN) / boardSize;
        
        for (NSInteger y = 0; y < boardSize; y++)
        {
            for (NSInteger x = 0; x < boardSize; x++)
            {
                SNGrotView *grot = [[SNGrotView alloc] initWithSize:cellSize- 2*GROT_SPACE];
                grot.position = [self positionForX:x Y:y];
                [self addChild:grot];
                [self.grots addObject:grot];
            }
        }
        
        [self addChild:self.menuView];
        [self addChild:self.bottomBar];
        [self addChild:self.menuButton];
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

- (void)makeMoveAtRow:(NSInteger)row column:(NSInteger)column
{
    SNGrotView *subview = (SNGrotView *)[self.grots objectAtIndex:column + row * boardSize];
    
    if ([subview isKindOfClass:[SNGrotView class]])
    {
        self.moves--;
        
        __block int newScore = 0;
        __block int newMoves = 0;
        
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
                    __block int animationsCount = 0;
                    
                    for (NSInteger y = 0; y < boardSize; y++)
                    {
                        for (NSInteger x = 0; x < boardSize; x++)
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
                                        [self addMoves:newMoves];
                                        [self addScore:newScore];
                                        
                                        isAnimatingTurn = NO;
                                        
                                        if (self.moves == 0) {
                                            [self endGame];
                                        }
                                    }
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
                        [self performBlockInCurrentThread:^{
                            animateFalling();
                        } afterDelay:0.1];
                    }];
                }
            };
            
            //start move
            animationsViews = [NSMutableArray new];
            
            [self nextGrot:field level:1];
            
            // count points
            NSMutableDictionary *collumnDictX = [NSMutableDictionary new];
            NSMutableDictionary *collumnDictY = [NSMutableDictionary new];
            
            for (SNGrotView *grot in animationsViews)
            {
                newScore += grot.model.value;
                CGPoint position = [self positionForGrot:grot];
                collumnDictX[[NSNumber numberWithInt:position.x]] = [collumnDictX[[NSNumber numberWithInt:position.x]] intValue] > 0 ?
                [NSNumber numberWithInt:[collumnDictX[[NSNumber numberWithInt:position.x]] intValue] + 1] : @1;
                
                collumnDictY[[NSNumber numberWithInt:position.y]] = [collumnDictY[[NSNumber numberWithInt:position.y]] intValue] > 0 ?
                [NSNumber numberWithInt:[collumnDictY[[NSNumber numberWithInt:position.y]] intValue] + 1] : @1;
                
            }
            
            int emptyRows = 0;
            int emptyColumns = 0;
            
            for (NSNumber *key in collumnDictX)
            {
                if ([[collumnDictX objectForKey:key] intValue] == boardSize)
                {
                    emptyColumns++;
                }
            }
            
            for (NSNumber *key in collumnDictY)
            {
                if ([[collumnDictY objectForKey:key] intValue] == boardSize)
                {
                    emptyRows++;
                }
            }
            
            newScore += (emptyColumns + emptyRows) * boardSize * 10;
            
            int threshold = floor((newScore + self.score) / (5 * boardSize * boardSize)) + boardSize - 1;
            
            if (threshold <= animationsViews.count)
            {
                newMoves = (int)animationsViews.count - threshold;
            }
            
            // make move
            
            animateMove();
        }
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
        
        if ([self convertPoint:location toColumn:&column row:&row] && self.moves > 0)
        {
            [self makeMoveAtRow:row column:column];
        }
        else
        {
            CGPoint touchLocation = [touch locationInNode:self];
            SKNode *touchedNode = [self nodeAtPoint:touchLocation];

            if ([touchedNode isEqual:self.menuButton])
            {
                [self toggleMenu];
            }
//            else if ([touchedNode isEqual:self.restart])
//            {
//                [self restartGame];
//            }
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
    if (point.x >= BOARD_MARGIN &&
        point.x < self.size.width - BOARD_MARGIN &&
        point.y >= BOARD_BOTTOM_MARGIN &&
        point.y < BOARD_BOTTOM_MARGIN + BOARD_MARGIN + boardSize*cellSize)
    {
        *column = (point.x - BOARD_MARGIN)/ cellSize;
        *row = (point.y - BOARD_BOTTOM_MARGIN - BOARD_MARGIN) / cellSize;
        
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
            if (newPosition.y < boardSize - level)
                newPosition.y += level;
            else
                return nil;
            break;
            
        case SNFieldDirectionRight:
            if (newPosition.x < boardSize - level)
                newPosition.x += level;
            else
                return nil;
            break;
    }
    
    SNGrotView *tempView = (SNGrotView *)[self.grots objectAtIndex:newPosition.x + newPosition.y * boardSize];
    
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

#pragma mark - Calculations

- (CGPoint)positionForX:(NSInteger)x Y:(NSInteger)y
{
    return CGPointMake(BOARD_MARGIN + cellSize/2 + x*cellSize, BOARD_BOTTOM_MARGIN + cellSize/2 + y*cellSize);
}

- (CGPoint)positionForGrot:(SNGrotView *)grot
{
    NSUInteger index = [self.grots indexOfObject:grot];
    
    if (index == NSNotFound)
    {
        return  CGPointZero;
    }
    
    int y = (int)index / boardSize;
    int x = (int)index - y*boardSize;
    
    return CGPointMake(x, y);
}

- (NSInteger)indexForPositon:(CGPoint)position
{
    return position.x + position.y*boardSize;
}

- (SNGrotView *)grotForPosition:(CGPoint)position
{
    return self.grots[(int)position.x + (int)position.y*boardSize];
}

- (SNGrotView *)grotForX:(NSInteger)x Y:(NSInteger)y
{
    return self.grots[x + y*boardSize];
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

- (void)addScore:(int)score
{
    if (score > 0)
    {
        self.scoreBonus.alpha = 1;
        self.scoreBonus.text = [NSString stringWithFormat:@"+%i", score];
        self.score += score;
        [self.scoreBonus runAction:[SKAction sequence:@[[SKAction waitForDuration:1],
                                                        [SKAction fadeAlphaTo:0 duration:0.5]]]];
    }
    else
    {
        self.scoreValue.text = @"";
    }
}

- (void)addMoves:(int)moves
{
    if (moves > 0)
    {
        self.movesBonus.alpha = 1;
        self.movesBonus.text = [NSString stringWithFormat:@"+%i", moves];
        self.moves += moves;
        
        [self.movesBonus runAction:[SKAction sequence:@[[SKAction waitForDuration:1],
                                                        [SKAction fadeAlphaTo:0 duration:0.5]]]];
    }
    else
    {
        self.movesBonus.text = @"";
    }
}

#pragma mark - Game action

- (void)showHelp
{
    if (!self.helpView)
    {
        self.helpView = [[SKSpriteNode alloc] initWithImageNamed:@"help"];
        self.helpView.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
    
    if ([self.helpView inParentHierarchy:self])
    {
        [self.helpView runAction:[SKAction removeFromParent]];
    }
    else
    {
        [self.helpView setScale:1];
        [self.helpView runAction:[SKAction scaleTo:self.frame.size.height/self.helpView.frame.size.height duration:0.1]];
        [self addChild:self.helpView];
    }
}

- (void)endGame
{
    for (SNGrotView *grot in self.grots)
    {
        [grot runAction:[SKAction sequence:@[[SKAction waitForDuration:0.3],
                                             [SKAction fadeAlphaTo:0.2 duration:0.4]]]];
        
    }
}

- (void)toggleMenu
{
    [self.menuView toggle];
    [self.menuButton toggle];
}

- (void)restartGame
{
    self.score = 0;
    self.moves = 5;
    
    for (SNGrotView *grot in self.grots)
    {
        [grot runAction:[SKAction fadeAlphaTo:1 duration:0.2]];
        [grot randomize];
    }
}

@end
