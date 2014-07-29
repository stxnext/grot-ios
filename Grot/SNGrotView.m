//
//  SNGrotFieldView.m
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGrotView.h"
#import "SNGrotFieldModel.h"
#import "UIBezierPath+Image.h"
@implementation SNGrotView

- (id)initWithSize:(CGFloat)size
{
    SNGrotFieldModel *model = [SNGrotFieldModel randomModel];
    
    self = [super initWithTexture:[SKTexture textureWithCGImage:[[self.class arrowPathWithSize:size] strokeImageWithColor:model.color].CGImage]
                            color:[UIColor redColor]
                             size:CGSizeMake(size, size)];
    
    if (self)
    {
        [self randomize];
    }
    
    return self;
}

- (void)randomize
{
    self.model = [SNGrotFieldModel randomModel];
    self.zRotation = -_model.angle;
}

+ (UIBezierPath *)arrowPathWithSize:(CGFloat)fieldSize
{
    static UIBezierPath* bezierPath;
    
    bezierPath = UIBezierPath.bezierPath;
    
    [bezierPath addArcWithCenter:CGPointMake(bezierPath.bounds.size.width/2, bezierPath.bounds.size.height/2)
                          radius:fieldSize/2
                      startAngle:0
                        endAngle:2*M_PI
                       clockwise:YES];
    
    
    static UIBezierPath* arrowBezierPath;
    
    arrowBezierPath = UIBezierPath.bezierPath;
    
    [arrowBezierPath moveToPoint: CGPointMake(0.145, 0.495)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.1453, 0.4758)];
    [arrowBezierPath addCurveToPoint: CGPointMake(0.1904, 0.4321) controlPoint1: CGPointMake(0.1453, 0.4758) controlPoint2: CGPointMake(0.1388, 0.4321)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.6364, 0.4321)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.4353, 0.2362)];
    [arrowBezierPath addCurveToPoint: CGPointMake(0.4353, 0.18) controlPoint1: CGPointMake(0.4353, 0.2362) controlPoint2: CGPointMake(0.3966, 0.2175)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.4675, 0.1489)];
    [arrowBezierPath addCurveToPoint: CGPointMake(0.5255, 0.1489) controlPoint1: CGPointMake(0.4675, 0.1489) controlPoint2: CGPointMake(0.4933, 0.1177)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.8478, 0.4607)];
    [arrowBezierPath addCurveToPoint: CGPointMake(0.8478, 0.5293) controlPoint1: CGPointMake(0.8478, 0.4607) controlPoint2: CGPointMake(0.8865, 0.4919)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.5255, 0.8411)];
    [arrowBezierPath addCurveToPoint: CGPointMake(0.4675, 0.8411) controlPoint1: CGPointMake(0.5255, 0.8411) controlPoint2: CGPointMake(0.4998, 0.8723)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.4353, 0.81)];
    [arrowBezierPath addCurveToPoint: CGPointMake(0.4353, 0.7538) controlPoint1: CGPointMake(0.4353, 0.81) controlPoint2: CGPointMake(0.3966, 0.7912)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.6364, 0.5579)];
    [arrowBezierPath addLineToPoint: CGPointMake(0.1904, 0.5579)];
    [arrowBezierPath addCurveToPoint: CGPointMake(0.1453, 0.5242) controlPoint1: CGPointMake(0.1904, 0.5579) controlPoint2: CGPointMake(0.1453, 0.5641)];
    
    [arrowBezierPath closePath];
    
    
    [arrowBezierPath applyTransform:CGAffineTransformIdentity];
    
    [arrowBezierPath applyTransform:CGAffineTransformMakeScale(fieldSize, fieldSize)];
    [arrowBezierPath applyTransform:CGAffineTransformMakeTranslation(-fieldSize/2 , -fieldSize/2)];
    
    [bezierPath appendPath:arrowBezierPath];
    //    [arrowBezierPath appendPath:bezierPath];
    bezierPath.usesEvenOddFillRule = YES;
    //    [bezierPath addClip];
    
    //    return arrowBezierPath;
    
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
