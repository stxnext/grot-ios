//
//  SKAction+Spring.m
//  Grot
//
//  Created by Dawid Żakowski on 14/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SKAction+Spring.h"
#import "SpringMath.h"
#import "SKTEffects.h"

@implementation SKAction (Spring)

+ (SKAction*)springActionOnProperty:(NSString*)property
                          fromValue:(CGFloat)start
                            toValue:(CGFloat)end
                           duration:(NSTimeInterval)duration
                          stiffness:(CGFloat)stiffness
                            bounces:(NSUInteger)bounces
                    shouldOvershoot:(BOOL)overshoot
{
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsed) {
        CGFloat value = springValue(elapsed / duration, start, end, duration, stiffness, (int)bounces, overshoot);
        [node setValue:@(value) forKey:property];
    }];
}

+ (SKAction*)springActionOnProperty:(NSString*)property
                          fromPoint:(CGPoint)start
                            toPoint:(CGPoint)end
                           duration:(NSTimeInterval)duration
                          stiffness:(CGFloat)stiffness
                            bounces:(NSUInteger)bounces
                    shouldOvershoot:(BOOL)overshoot
{
    return [SKAction customActionWithDuration:duration actionBlock:^(SKNode *node, CGFloat elapsed) {
        double normalizedValue = springValue(elapsed / duration, 0.0, 1.0, duration, stiffness, (int)bounces, overshoot);
        CGPoint currentPoint = (CGPoint){ start.x + (end.x - start.x) * normalizedValue, start.y + (end.y - start.y) * normalizedValue };
        NSValue* currentValue = [NSValue valueWithCGPoint:currentPoint];
        [node setValue:currentValue forKeyPath:property];
    }];
}

+ (SKAction*)springSKTActionOnNode:(SKNode*)node
                         fromPoint:(CGPoint)start
                           toPoint:(CGPoint)end
                          duration:(NSTimeInterval)duration
{
    SKTMoveEffect* effect = [SKTMoveEffect effectWithNode:node
                                                 duration:duration
                                            startPosition:start
                                              endPosition:end];
    
    effect.timingFunction = SKTTimingFunctionBounceEaseOut;
    
    SKAction* action = [SKAction actionWithEffect:effect];
    return action;
}

@end
