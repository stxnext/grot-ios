//
//  SNMenuView.m
//  Grot
//
//  Created by Adam on 23.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNMenuView.h"

@implementation SNMenuView

int size = 350;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.lineWidth = 0.5;
        isHiden = YES;
        
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-size/2, -size/2, size, size)];
        
        self.path =  circle.CGPath;
        
        self.fillColor = [UIColor colorWithWhite:0.15 alpha:1];
        self.strokeColor = [UIColor colorWithWhite:0.4 alpha:1];
        self.lineWidth = 3;

        self.position = CGPointMake(-size, -size);
        
        self.level1Button = [[SNNewGameButton alloc] initWithLevel:SNGameLevelFast];
        self.level2Button = [[SNNewGameButton alloc] initWithLevel:SNGameLevelMedium];
        self.level3Button = [[SNNewGameButton alloc] initWithLevel:SNGameLevelSlow];        
                
        [self addChild:self.level1Button];
        [self addChild:self.level2Button];
        [self addChild:self.level3Button];
        
        CGFloat buttonSize = 0;//self.level1Button.frame.size.width / 2;
        self.level1Button.position = CGPointMake(size/2 * cos(M_PI_2 * 9/10) - buttonSize,
                                                 size/2 * sin(M_PI_2 * 9/10) - buttonSize);
        
        self.level2Button.position = CGPointMake(size/2 * cos(M_PI_2 * 5.5/10) - buttonSize,
                                                 size/2 * sin(M_PI_2 * 5.5/10) - buttonSize);
        
        self.level3Button.position = CGPointMake(size/2 * cos(M_PI_2 * 2/10) - buttonSize,
                                                 size/2 * sin(M_PI_2 * 2/10) - buttonSize);
    }
    
    return self;
}

- (void)toggle
{
    if (isHiden)
    {
        SKAction *showMenuAction = [SKAction moveTo:CGPointMake(30, 30) duration:0.4];
        showMenuAction.timingMode = SKActionTimingEaseOut;
        [self runAction:showMenuAction ];
    }
    else
    {
        SKAction *hideMenuAction = [SKAction moveTo:CGPointMake(-size, -size) duration:0.4];
        hideMenuAction.timingMode = SKActionTimingEaseIn;
        [self runAction:hideMenuAction];
    }
    
    isHiden = !isHiden;
}


@end
