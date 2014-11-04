//
//  SKAction+Spring.h
//  Grot
//
//  Created by Dawid Żakowski on 14/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKAction (Spring)

+ (SKAction*)springActionOnProperty:(NSString*)property
                          fromValue:(CGFloat)start
                            toValue:(CGFloat)end
                           duration:(NSTimeInterval)duration
                          stiffness:(CGFloat)stiffness
                            bounces:(NSUInteger)bounces
                    shouldOvershoot:(BOOL)overshoot;

+ (SKAction*)springActionOnProperty:(NSString*)property
                          fromPoint:(CGPoint)start
                            toPoint:(CGPoint)end
                           duration:(NSTimeInterval)duration
                          stiffness:(CGFloat)stiffness
                            bounces:(NSUInteger)bounces
                    shouldOvershoot:(BOOL)overshoot;

+ (SKAction*)springSKTActionOnNode:(SKNode*)node
                         fromPoint:(CGPoint)start
                           toPoint:(CGPoint)end
                          duration:(NSTimeInterval)duration;

@end
