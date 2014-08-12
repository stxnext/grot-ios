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
#import "UIImage+Blending.h"
#import "UIColor+Blending.h"

@implementation SNGrotView

- (id)initWithSize:(CGFloat)size
{
    self = [super initWithColor:[UIColor blackColor] size:CGSizeMake(size, size)];
    
    if (self)
    {
        [self randomize];
    }
    
    return self;
}

- (void)randomize
{
    self.model = [SNGrotFieldModel randomModel];
    
    // sprite
    UIImage* sprite = [self.class generateSpriteWithSize:self.size color:self.model.color angle:_model.angle];
    self.texture = [SKTexture textureWithCGImage:sprite.CGImage];
}

+ (UIImage*)generateSpriteWithSize:(CGSize)size color:(UIColor*)color angle:(CGFloat)angle
{
    UIColor* darkColor = [color blendWithColor:UIColor.darkGrayColor percent:0.6];
    UIColor* arrowColor = colorFromHex(0x404040);
    UIBezierPath* arrowPath = [self.class arrowPathWithSize:size.width];
    UIBezierPath* circlePath = [self.class circlePathWithSize:size.width];
    UIImage* circleImage = [circlePath fillImageWithGradientFromColor:darkColor toColor:color];
    UIImage* arrowImage = [arrowPath fillImageWithColor:arrowColor];
    arrowImage = [arrowImage rotateWithAngle:angle];
    UIImage* combinedImage = [circleImage addImage:arrowImage];
    
    return combinedImage;
}

+ (UIBezierPath*)circlePathWithArrowMaskAndSize:(CGFloat)circleSize
{
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath appendPath:[self circlePathWithSize:circleSize]];
    [bezierPath appendPath:[self arrowPathWithSize:circleSize]];
    
    bezierPath.usesEvenOddFillRule = YES;
    
    return bezierPath;
}

+ (UIBezierPath*)arrowPathWithSize:(CGFloat)fieldSize
{
    UIBezierPath* arrowBezierPath = UIBezierPath.bezierPath;
    
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
    
    const static CGFloat arrowScale = 0.75;
    CGFloat arrowSize = fieldSize * arrowScale;
    
    [arrowBezierPath applyTransform:CGAffineTransformIdentity];
    [arrowBezierPath applyTransform:CGAffineTransformMakeScale(arrowSize, arrowSize)];
    [arrowBezierPath applyTransform:CGAffineTransformMakeTranslation(-arrowSize/2 , -arrowSize/2)];
    
    return arrowBezierPath;
}

+ (UIBezierPath*)circlePathWithSize:(CGFloat)circleSize
{
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    
    [bezierPath addArcWithCenter:CGPointMake(bezierPath.bounds.size.width/2, bezierPath.bounds.size.height/2)
                          radius:circleSize/2
                      startAngle:0
                        endAngle:2*M_PI
                       clockwise:YES];
    
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %g",NSStringFromCGPoint(self.model.position), self.model.angle];
}

@end
