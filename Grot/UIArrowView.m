//
//  UIArrowView.m
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIArrowView.h"
#import "UIColor+Parser.h"
#import "UIBezierPath+Image.h"
#import "UIImage+Blending.h"

@implementation UIArrowView

#pragma mark - Setters

- (void)setModel:(NSArrowField *)model
{
    _model = model;
    [self reloadTexture];
}

- (void)setSize:(CGSize)size
{
    [super setSize:size];
    [self reloadTexture];
}

#pragma mark - Sprite generation

- (void)reloadTexture
{
    if (self.size.width * self.size.height == 0)
        return;
    
    if (!self.model)
        return;
    
    UIImage* sprite = [self.class generateSpriteWithSize:self.size type:_model.type angle:_model.angle];
    self.texture = [SKTexture textureWithCGImage:sprite.CGImage];
}

+ (UIImage*)generateSpriteWithSize:(CGSize)size type:(NSArrowFieldType)type angle:(CGFloat)angle
{
    UIColor* backgroundColor = NSArrowField.backgroundColors[@(type)];
    UIColor* arrowColor = NSArrowField.arrowColor;
    UIBezierPath* arrowPath = [self.class arrowPathWithSize:size.width];
    UIBezierPath* circlePath = [self.class circlePathWithSize:size.width];
    UIImage* circleImage = [circlePath fillImageWithColor:backgroundColor];
    UIImage* arrowImage = [arrowPath fillImageWithColor:arrowColor];
    arrowImage = [arrowImage rotateWithAngle:-angle];
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

#pragma mark - Tap handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(arrowViewTouchedDown:)])
    {
        [self.delegate arrowViewTouchedDown:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch* touch = touches.anyObject;
    CGPoint point = [touch locationInNode:self.parent];
    BOOL isTouchUpInside = [self containsPoint:point];
    
    if ([self.delegate respondsToSelector:@selector(arrowViewTouchedUp:inside:)])
    {
        [self.delegate arrowViewTouchedUp:self inside:isTouchUpInside];
    }
}

@end
