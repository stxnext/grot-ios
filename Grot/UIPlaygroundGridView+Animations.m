//
//  UIPlaygroundGridView+Animations.m
//  Grot
//
//  Created by Dawid Żakowski on 16/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIPlaygroundGridView+Animations.h"
#import "SKAction+Spring.h"
#import "CGPoint+Distance.h"
#import "SKTEffects.h"

typedef CF_ENUM(NSUInteger, UIArrowTransitionAnimation) {
    UIArrowTransitionAnimationReaction,
    UIArrowTransitionAnimationPushDown,
    UIArrowTransitionAnimationStraight
};

const CGFloat UIArrowReactionMovementSpeed = 4.0;
const CGFloat UIArrowPushDownMovementSpeed = 1.5;
const CGFloat UIArrowStraightMovementSpeed = 3.0;
const CGFloat UIArrowHighlightOnSpeed = 8.0;
const CGFloat UIArrowHighlightOffSpeed = 3.0;

@implementation UIPlaygroundGridView (Animations)

#pragma mark - Initial fade in

- (void)animateFadeInForArrowViews:(NSArray*)arrowViews completionHandler:(void (^)())completionBlock
{
    for (NSUInteger i = 0; i < arrowViews.count; i++)
    {
        UIArrowView* arrowView = arrowViews[i];
        
        NSTimeInterval waitDuration = i * 0.03;
        const NSTimeInterval alphaDuration = 0.4;
        const NSTimeInterval scaleDuration = 1.4;
        
        SKAction* delayAction = [SKAction waitForDuration:waitDuration];
        SKAction* alphaAction = [SKAction fadeInWithDuration:alphaDuration];
        SKAction* scaleAction = [SKAction springActionOnProperty:@"scale" fromValue:0.0 toValue:1.0 duration:scaleDuration stiffness:0.02 bounces:2 shouldOvershoot:YES];
        SKAction* fadeInActionGroup = [SKAction group:@[ alphaAction, scaleAction ]];
        SKAction* actionSequence = [SKAction sequence:@[ delayAction, fadeInActionGroup ]];
        
        BOOL isLastIteration = i == arrowViews.count - 1;
        dispatch_block_t block = isLastIteration ? completionBlock : nil;
        [arrowView runAction:actionSequence completion:block];
    }
}

- (void)animateFadeOutForArrowViews:(NSArray*)arrowViews completionHandler:(void (^)())completionBlock
{
    for (NSUInteger i = 0; i < arrowViews.count; i++)
    {
        UIArrowView* arrowView = arrowViews[i];
        
        const NSTimeInterval scaleDuration = 0.5;
        NSTimeInterval scaleUpDuration = scaleDuration * 1.0 / 3.0;
        NSTimeInterval scaleDownDuration = scaleDuration * 2.0 / 3.0;
        
        SKAction* scaleUpAction = [SKAction scaleTo:1.2 duration:scaleUpDuration];
        scaleUpAction.timingMode = SKActionTimingEaseOut;
        SKAction* scaleDownAction = [SKAction scaleTo:0.01 duration:scaleDownDuration];
        scaleDownAction.timingMode = SKActionTimingEaseIn;
        SKAction* alphaAction = [SKAction fadeOutWithDuration:scaleDownDuration];
        alphaAction.timingMode = SKActionTimingEaseOut;
        SKAction* actionSequence = [SKAction sequence:@[ scaleUpAction, [SKAction group:@[ alphaAction, scaleDownAction ]] ]];
        
        BOOL isLastIteration = i == arrowViews.count - 1;
        dispatch_block_t block = isLastIteration ? completionBlock : nil;
        [arrowView runAction:actionSequence completion:block];
    }
}

#pragma mark - Chain reaction

- (void)animateReaction:(NSFieldReaction*)reaction withCompletionHandler:(void (^)())completionBlock
{
    NSFieldTransition* transition = [reaction popTransition];
    
    if (!transition)
    {
        if (completionBlock)
            dispatch_async(dispatch_get_main_queue(), completionBlock);
        
        return;
    }
    
    SKAction* action = [self actionForTransition:transition withAnimation:UIArrowTransitionAnimationReaction];
    __block UIArrowView* arrowView = [self arrowViewForArrowField:transition.arrowField];
    
    [arrowView runAction:action completion:^{
        [arrowView removeFromParent];
        
        [self animateReaction:reaction withCompletionHandler:completionBlock];
    }];
}

- (SKAction*)actionForTransition:(NSFieldTransition*)transition withAnimation:(UIArrowTransitionAnimation)animation
{
    NSGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    UIArrowView* arrowView = [self arrowViewForArrowField:transition.arrowField];
    CGPoint location = [self locationForNodePosition:transition.endpointPosition inGridOfSize:grid.size];

    CGFloat unitDistance = ((self.itemSize.width + self.itemSpacing.width) + (self.itemSize.height + self.itemSpacing.height)) * 0.5;
    CGFloat movementDistance = CGPointDistance(arrowView.position, location);
    CGFloat movementMultiply = MAX(1.0, movementDistance / unitDistance);
    
    switch (animation)
    {
        case UIArrowTransitionAnimationReaction:
        {
            NSTimeInterval actionDuration = movementMultiply / UIArrowReactionMovementSpeed;
            
            if (movementDistance > unitDistance)
            {
                CGFloat viaDistance = movementDistance - unitDistance;
                CGFloat viaDistanceFactor = viaDistance / movementDistance;
                NSTimeInterval fadeDuration =  actionDuration * (1.0 - viaDistanceFactor);
                SKAction* alphaAction = [SKAction fadeAlphaTo:0.0 duration:fadeDuration];
                SKAction* moveAction = [SKAction moveTo:location duration:fadeDuration];
                SKAction* fadedMoveAction = [SKAction group:@[ alphaAction, moveAction ]];
                fadedMoveAction.timingMode = SKActionTimingEaseOut;
                
                NSTimeInterval viaDuration = actionDuration * viaDistanceFactor;
                CGPoint viaLocation = CGPointMake(arrowView.position.x + (location.x - arrowView.position.x) * viaDistanceFactor,
                                                  arrowView.position.y + (location.y - arrowView.position.y) * viaDistanceFactor);
                
                SKAction* flatMoveAction = [SKAction moveTo:viaLocation duration:viaDuration];
                
                SKAction* transitionAction = [SKAction sequence:@[ flatMoveAction, fadedMoveAction ]];
                
                return transitionAction;
            }
            else
            {
                SKAction* alphaAction = [SKAction fadeAlphaTo:0.0 duration:actionDuration];
                SKAction* moveAction = [SKAction moveTo:location duration:actionDuration];
                SKAction* fadedMoveAction = [SKAction group:@[ alphaAction, moveAction ]];
                fadedMoveAction.timingMode = SKActionTimingEaseOut;
                
                return fadedMoveAction;
            }
        }
            
        case UIArrowTransitionAnimationPushDown:
        {
            NSTimeInterval moveDuration = 1.0 / UIArrowPushDownMovementSpeed;

            SKAction* action = [SKAction springSKTActionOnNode:arrowView fromPoint:arrowView.position toPoint:location duration:moveDuration];
            
            return action;
        }
            
        case UIArrowTransitionAnimationStraight:
        {
            NSTimeInterval moveDuration = 1.0 / UIArrowStraightMovementSpeed;
            
            SKAction* action = [SKAction moveTo:location duration:moveDuration];
            
            return action;
        }
            
        default:
        {
            @throw [NSException new];
        }
    }
}

#pragma mark - Push down

- (void)animatePushDownIntoGrid:(NSGameGrid*)targetGrid withCompletionHandler:(void (^)())completionBlock
{
    __block NSNumber* activeAnimations = @(0);
    
    NSArray* transitions = [self transitionsForPushDownIntoGrid:targetGrid];
    
    if (transitions.count == 0)
    {
        if (completionBlock)
            dispatch_async(dispatch_get_main_queue(), completionBlock);
        
        return;
    }
    
    for (NSFieldTransition* transition in transitions)
    {
        @synchronized (activeAnimations)
        {
            activeAnimations = @( activeAnimations.integerValue + 1 );
        }
        
        UIArrowView* arrowView = [self arrowViewForArrowField:transition.arrowField];
        SKAction* action = [self actionForTransition:transition withAnimation:UIArrowTransitionAnimationPushDown];
        
        [arrowView runAction:action completion:^{
            @synchronized (activeAnimations)
            {
                activeAnimations = @( activeAnimations.integerValue - 1 );
                
                if (activeAnimations.integerValue == 0)
                {
                    if (completionBlock)
                        dispatch_async(dispatch_get_main_queue(), completionBlock);
                }
            }
        }];
    }
}

- (NSArray*)transitionsForPushDownIntoGrid:(NSGameGrid*)targetGrid
{
    NSGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    NSMutableArray* transitions = NSMutableArray.array;
    
    for (NSArrowField* arrowField in grid.allObjects)
    {
        CGPoint sourcePoint = [grid pointForObject:arrowField];
        CGPoint targetPoint = [targetGrid pointForObject:arrowField];
        
        if (CGPointEqualToPoint(sourcePoint, targetPoint) || CGPointEqualToPoint(targetPoint, NSGridInvalidPoint))
            continue;
        
        NSFieldTransition* transition = NSFieldTransition.new;
        transition.arrowField = arrowField;
        transition.endpointPosition = targetPoint;
        
        [transitions addObject:transition];
    }
    
    return transitions;
}

#pragma mark - Highlight

- (void)animateHighlightOfArrowView:(UIArrowView*)arrowView toState:(BOOL)highlighted
{
    if (highlighted)
    {
        CGFloat alpha = 0.4;
        NSTimeInterval duration = 1.0 / UIArrowHighlightOnSpeed;
        
        SKAction* action = [SKAction fadeAlphaTo:alpha duration:duration];
        action.timingMode = SKActionTimingEaseIn;
        [arrowView runAction:action];
    }
    else
    {
        CGFloat alpha = 1.0;
        NSTimeInterval duration = 1.0 / UIArrowHighlightOffSpeed;
        
        SKAction* action = [SKAction fadeAlphaTo:alpha duration:duration];
        action.timingMode = SKActionTimingEaseIn;
        [arrowView runAction:action];
    }
}

@end
