//
//  SNNewGameButton.m
//  Grot
//
//  Created by Adam on 24.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNNewGameButton.h"

@implementation SNNewGameButton

- (id)initWithLevel:(SNGameLevel)level
{
    CGFloat size = 50;
    
    switch (level)
    {
        case SNGameLevelFast:
            self = [super initWithTexture:[SKTexture textureWithCGImage:[UIImage imageNamed:@"level1"].CGImage] color:[UIColor clearColor] size:CGSizeMake(size, size)];
            break;
        case SNGameLevelMedium:
            self = [super initWithTexture:[SKTexture textureWithCGImage:[UIImage imageNamed:@"level2"].CGImage] color:[UIColor clearColor] size:CGSizeMake(size, size)];
            break;
        case SNGameLevelSlow:
            self = [super initWithTexture:[SKTexture textureWithCGImage:[UIImage imageNamed:@"level3"].CGImage] color:[UIColor clearColor] size:CGSizeMake(size, size)];
            break;
            
        default:
            break;
    }
    
    if (self)
    {
//        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size, size)];
//        
//        self.path =  circle.CGPath;
//        self.fillColor = [UIColor colorWithWhite:0.1 alpha:1];
//        self.strokeColor = [UIColor colorWithWhite:0.5 alpha:1];
//        self.lineWidth = 2;

        [self setNameForNode:self withLevel:level];
//        [self generateViewForLevel:level];
    }
    
    return self;
}
/*
- (void)generateViewForLevel:(SNGameLevel)level
{
    CGFloat circleSize = (self.frame.size.height - 2*self.lineWidth) / level - 5;
    CGFloat areaSize = 2*pow(pow((self.frame.size.height - 2*self.lineWidth)/2, 2)/2, 0.5);
    CGFloat offset = (self.frame.size.width - areaSize) / 2 + 1;
    
    for (int x = 0; x < level; x++)
    {
        for (int y = 0; y < level; y++)
        {
            SKShapeNode *node = [SKShapeNode new];
            UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, circleSize, circleSize)];
            
            node.path =  circle.CGPath;
            node.fillColor = [UIColor colorWithWhite:0.5 alpha:0];
            node.strokeColor = [UIColor colorWithWhite:0.5 alpha:.75];
            node.lineWidth = 1;

            node.position = CGPointMake(offset + areaSize/level * x,
                                        offset + areaSize/level * y);
            
            [self addChild:node];
            
            [self setNameForNode:node withLevel:level];
        }
    }
}
*/
- (void)setNameForNode:(SKNode *)node withLevel:(SNGameLevel)level
{
    switch (level)
    {
        case SNGameLevelFast:
            node.name = @"level1Button";
            break;
            
        case SNGameLevelMedium:
            node.name = @"level2Button";
            break;
            
        case SNGameLevelSlow:
            node.name = @"level3Button";
            break;
            
        default:
            break;
    }
}

@end
