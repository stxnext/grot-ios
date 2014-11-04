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
    UIArrowTransitionAnimationPushDown
};

const CGFloat UIArrowReactionMovementSpeed = 3.0;
const CGFloat UIArrowPushDownMovementSpeed = 1.5;

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

#pragma mark - Chain reaction

- (void)animateReaction:(SNFieldReaction*)reaction withCompletionHandler:(void (^)())completionBlock
{
    SNFieldTransition* transition = [reaction popTransition];
    
    if (!transition)
    {
        if (completionBlock)
            completionBlock();
        
        return;
    }
    
    SKAction* action = [self actionForTransition:transition withAnimation:UIArrowTransitionAnimationReaction];
    __block UIArrowView* arrowView = [self arrowViewForArrowField:transition.arrowField];
    
    [arrowView runAction:action completion:^{
        [arrowView removeFromParent];
        
        [self animateReaction:reaction withCompletionHandler:completionBlock];
    }];
}

- (SKAction*)actionForTransition:(SNFieldTransition*)transition withAnimation:(UIArrowTransitionAnimation)animation
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
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
                
                NSTimeInterval viaDuration = actionDuration * viaDistanceFactor;
                CGPoint viaLocation = CGPointMake(arrowView.position.x + (location.x - arrowView.position.x) * viaDistanceFactor,
                                                  arrowView.position.y + (location.y - arrowView.position.y) * viaDistanceFactor);
                
                SKAction* flatMoveAction = [SKAction moveTo:viaLocation duration:viaDuration];
                flatMoveAction.timingMode = SKActionTimingEaseIn;
                
                SKAction* transitionAction = [SKAction sequence:@[ flatMoveAction, fadedMoveAction ]];
                
                return transitionAction;
            }
            else
            {
                SKAction* alphaAction = [SKAction fadeAlphaTo:0.0 duration:actionDuration];
                SKAction* moveAction = [SKAction moveTo:location duration:actionDuration];
                SKAction* fadedMoveAction = [SKAction group:@[ alphaAction, moveAction ]];
                fadedMoveAction.timingMode = SKActionTimingEaseIn;
                
                return fadedMoveAction;
            }
        }
            
        case UIArrowTransitionAnimationPushDown:
        {
            NSTimeInterval moveDuration = 1.0 / UIArrowPushDownMovementSpeed;

            SKAction* action = [SKAction springSKTActionOnNode:arrowView fromPoint:arrowView.position toPoint:location duration:moveDuration];
            
            return action;
        }
        
        default:
        {
            @throw [NSException new];
        }
    }
}

#pragma mark - Push down

- (void)animatePushDownIntoGrid:(SNGameGrid*)targetGrid withCompletionHandler:(void (^)())completionBlock
{
    __block NSNumber* activeAnimations = @(0);
    
    NSArray* transitions = [self transitionsForPushDownIntoGrid:targetGrid];
    
    if (transitions.count == 0)
    {
        if (completionBlock)
            completionBlock();
        
        return;
    }
    
    for (SNFieldTransition* transition in transitions)
    {
        @synchronized (activeAnimations)
        {
            activeAnimations = @( activeAnimations.integerValue + 1 );
        }
        
        UIArrowView* arrowView = [self arrowViewForArrowField:transition.arrowField];
        SKAction* action = [self actionForTransition:transition withAnimation:UIArrowTransitionAnimationPushDown];
        [arrowView runAction:action];
        
        [arrowView runAction:action completion:^{
            @synchronized (activeAnimations)
            {
                activeAnimations = @( activeAnimations.integerValue - 1 );
                
                if (activeAnimations.integerValue == 0)
                {
                    if (completionBlock)
                        completionBlock();
                }
            }
        }];
    }
}

- (NSArray*)transitionsForPushDownIntoGrid:(SNGameGrid*)targetGrid
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    NSMutableArray* transitions = NSMutableArray.array;
    
    for (SNArrowField* arrowField in grid.allObjects)
    {
        CGPoint sourcePoint = [grid pointForObject:arrowField];
        CGPoint targetPoint = [targetGrid pointForObject:arrowField];
        
        if (CGPointEqualToPoint(sourcePoint, targetPoint) || CGPointEqualToPoint(targetPoint, SNGridInvalidPoint))
            continue;
        
        SNFieldTransition* transition = SNFieldTransition.new;
        transition.arrowField = arrowField;
        transition.endpointPosition = targetPoint;
        
        [transitions addObject:transition];
    }
    
    return transitions;
}

@end
