//
//  SNMenuButton.m
//  Grot
//
//  Created by Adam on 23.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNMenuButton.h"

@implementation SNMenuButton

- (id)initWithSize:(CGFloat)size angle:(CGFloat)angle
{
    self = [super init];
    
    if (self)
    {
        self.lineWidth = 0.5;
        
        UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-size/2, -size/2, size, size)];
        UIBezierPath *arrow = [self.class arrowPathWithSize:size];
        
        [circle appendPath:arrow];
        
        self.path =  circle.CGPath;
        
        self.zRotation = angle;
        
        self.fillColor = [UIColor colorWithWhite:0.15 alpha:0.51];//[UIColor colorWithRed:0/255. green:160/255. blue:155/255. alpha:1];

        self.strokeColor = [UIColor colorWithWhite:0.65 alpha:0.5];
        self.lineWidth = 0.5;
        
        self.position = CGPointMake(30, 30);
    }
    
    return self;
}


- (void)toggle
{
//    [self runAction:[SKAction rotateByAngle:M_PI duration:0.4]];
    self.zRotation += M_PI;
    
    isOpen = !isOpen;

    if (isOpen)
    {
        self.strokeColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    }
    else
    {
        self.strokeColor = [UIColor colorWithWhite:0.65 alpha:0.5];
    }
}

+ (UIBezierPath *)arrowPathWithSize:(CGFloat)fieldSize
{
    static UIBezierPath* bezierPath;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bezierPath = UIBezierPath.bezierPath;
        
        [bezierPath moveToPoint: CGPointMake(0.145, 0.495)];
        [bezierPath addLineToPoint: CGPointMake(0.1453, 0.4758)];
        [bezierPath addCurveToPoint: CGPointMake(0.1904, 0.4321) controlPoint1: CGPointMake(0.1453, 0.4758) controlPoint2: CGPointMake(0.1388, 0.4321)];
        [bezierPath addLineToPoint: CGPointMake(0.6364, 0.4321)];
        [bezierPath addLineToPoint: CGPointMake(0.4353, 0.2362)];
        [bezierPath addCurveToPoint: CGPointMake(0.4353, 0.18) controlPoint1: CGPointMake(0.4353, 0.2362) controlPoint2: CGPointMake(0.3966, 0.2175)];
        [bezierPath addLineToPoint: CGPointMake(0.4675, 0.1489)];
        [bezierPath addCurveToPoint: CGPointMake(0.5255, 0.1489) controlPoint1: CGPointMake(0.4675, 0.1489) controlPoint2: CGPointMake(0.4933, 0.1177)];
        [bezierPath addLineToPoint: CGPointMake(0.8478, 0.4607)];
        [bezierPath addCurveToPoint: CGPointMake(0.8478, 0.5293) controlPoint1: CGPointMake(0.8478, 0.4607) controlPoint2: CGPointMake(0.8865, 0.4919)];
        [bezierPath addLineToPoint: CGPointMake(0.5255, 0.8411)];
        [bezierPath addCurveToPoint: CGPointMake(0.4675, 0.8411) controlPoint1: CGPointMake(0.5255, 0.8411) controlPoint2: CGPointMake(0.4998, 0.8723)];
        [bezierPath addLineToPoint: CGPointMake(0.4353, 0.81)];
        [bezierPath addCurveToPoint: CGPointMake(0.4353, 0.7538) controlPoint1: CGPointMake(0.4353, 0.81) controlPoint2: CGPointMake(0.3966, 0.7912)];
        [bezierPath addLineToPoint: CGPointMake(0.6364, 0.5579)];
        [bezierPath addLineToPoint: CGPointMake(0.1904, 0.5579)];
        [bezierPath addCurveToPoint: CGPointMake(0.1453, 0.5242) controlPoint1: CGPointMake(0.1904, 0.5579) controlPoint2: CGPointMake(0.1453, 0.5641)];
        
        [bezierPath closePath];
        
        [bezierPath applyTransform:CGAffineTransformMakeScale(fieldSize, fieldSize)];
        [bezierPath applyTransform:CGAffineTransformMakeTranslation(-fieldSize/2 , -fieldSize/2)];
    });
    
    return bezierPath;
}

@end
