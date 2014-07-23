//
//  SNMenuView.m
//  Grot
//
//  Created by Adam on 23.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNMenuView.h"

@implementation SNMenuView

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.lineWidth = 0.5;
        isHiden = YES;
        
        int size = 500;
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-size/2, -size/2, size, size)];
        
        //circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-10/2, -10/2, 10, 10)];
        
        self.path =  circle.CGPath;
        
        
        
        self.fillColor = [UIColor colorWithWhite:0.15 alpha:1];//[UIColor colorWithRed:0/255. green:160/255. blue:155/255. alpha:1];
        
        self.strokeColor = [UIColor colorWithWhite:0.1 alpha:1];
        self.lineWidth = 1;
        self.antialiased = YES;
        self.position = CGPointMake(-500, -500);
    }
    
    return self;
}

- (void)toggle
{
    if (isHiden)
    {
        SKAction *action = [SKAction moveTo:CGPointMake(30, 30) duration:0.4];
//        action.speed = 2; 
        [self runAction:action];
    }
    else
    {
        SKAction *action = [SKAction moveTo:CGPointMake(-500, -500) duration:0.4];
//        action.speed = 2;
        [self runAction:action];
    }
    
    isHiden = !isHiden;
}


@end
