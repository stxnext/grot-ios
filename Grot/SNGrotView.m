//
//  SNGrotFieldView.m
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGrotView.h"
#import "SNGrotFieldModel.h"

@implementation SNGrotView

- (id)initWithSize:(CGFloat)size
{
    self = [super init];
    
    if (self)
    {    
        [self setSize:size];
        fieldSize = size;
    }
    
    return self;
}

- (void)randomize
{
    [self setSize:fieldSize];
}

- (void)setSize:(CGFloat)size
{
    self.model = [SNGrotFieldModel randomModel];
    self.lineWidth = 0.5;
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-size/2, -size/2, size, size)];
    UIBezierPath *arrow = [self.class arrowPathWithSize:size];

    [circle appendPath:arrow];

    self.path =  circle.CGPath;
    
    self.zRotation = -_model.angle;

    self.fillColor = self.model.color;
    self.strokeColor = self.model.color;
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

- (CGPoint)center
{
    return CGPointMake(self.frame.origin.x + self.frame.size.width/2, self.frame.origin.y + self.frame.size.height/2);
}

- (void)setCenter:(CGPoint)center
{
    self.position = center;
}

@end
