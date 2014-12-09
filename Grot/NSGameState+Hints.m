//
//  NSGameState+Hints.m
//  Grot
//
//  Created by Dawid Żakowski on 07/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSGameState+Hints.h"
#import "NSArrowField.h"
#import "NSDictionary+Aggregation.h"

@implementation NSGameState (Hints)

- (NSDictionary*)transitions
{
    NSMutableDictionary* results = NSMutableDictionary.dictionary;
    
    for (NSInteger y = 0; y < self.grid.size.height; y++)
    {
        for (NSInteger x = 0; x < self.grid.size.width; x++)
        {
            CGPoint point = (CGPoint){ x, y };
            NSArrowField* field = [self.grid objectAtPoint:point];
            
            if (field && !field.isUnknown)
            {
                NSGameState* state = self.copy;
                NSArrowField* copyModel = [state.grid objectAtPoint:point];
                NSFieldReaction* reaction = [state scheduleReactionAtField:copyModel];
                NSGameResults* newResults = reaction.targetState.results;
                
                if (![newResults isEqual:NSGameResults.unknownResults])
                    results[field] = reaction.targetState.filledState;
            }
        }
    }
    
    return results;
}

- (NSDictionary*)transitionOptimizedForStatePropertyAtKeyPath:(NSString*)keyPath treeDepth:(NSInteger)depth
{
    NSDictionary* initialTransitions = self.transitions;
    
    if (initialTransitions.allKeys.count == 0)
        return nil;
    
    NSDictionary* analyzedTransitions = initialTransitions;
    
    if (depth > 0)
    {
        NSMutableDictionary* innerTransitions = NSMutableDictionary.dictionary;
        
        for (NSArrowField* field in initialTransitions.allKeys)
        {
            NSGameState* state = initialTransitions[field];
            NSDictionary* transition = [state transitionOptimizedForStatePropertyAtKeyPath:keyPath treeDepth:depth - 1];
            
            if (!transition)
                continue;
            
            innerTransitions[field] = transition.allValues.firstObject;
        }
        
        if (innerTransitions.allKeys.count == 0)
            return nil;
        
        analyzedTransitions = innerTransitions;
    }
    
    NSArrowField* bestModel = [analyzedTransitions keyForMaxValueUsingValueComparator:^NSComparisonResult(NSGameState* state1, NSGameState* state2) {
        NSInteger value1 = [[state1 valueForKeyPath:keyPath] integerValue];
        NSInteger value2 = [[state2 valueForKeyPath:keyPath] integerValue];
        
        if (value1 < value2)
            return NSOrderedAscending;
        else if (value1 == value2)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
    
    NSGameState* bestState = analyzedTransitions[bestModel];
    return @{ bestModel : bestState };
}

- (NSDictionary*)transitionOptimizedForMaxScoreWithTreeDepth:(NSInteger)depth
{
    return [self transitionOptimizedForStatePropertyAtKeyPath:@"results.score" treeDepth:depth];
}

- (NSDictionary*)transitionOptimizedForMaxMovesWithTreeDepth:(NSInteger)depth
{
    return [self transitionOptimizedForStatePropertyAtKeyPath:@"results.moves" treeDepth:depth];
}

- (NSDictionary*)transitionOptimizedForBestMovesBeforeScoreWithTreeDepth:(NSInteger)depth
{
    NSDictionary* movesTransision = [self transitionOptimizedForMaxMovesWithTreeDepth:depth];
    NSGameState* bestMovesState = movesTransision.allValues.firstObject;
    NSArrowField* bestModel;
    NSGameState* bestState;
    
    if (bestMovesState.results.moves > self.results.moves)
    {
        bestModel = movesTransision.allKeys.firstObject;
        bestState = bestMovesState;
    }
    else
    {
        NSDictionary* scoreTransition = [self transitionOptimizedForMaxScoreWithTreeDepth:depth];
        bestModel = scoreTransition.allKeys.firstObject;
        bestState = scoreTransition.allValues.firstObject;
    }
    
    if (!bestModel || !bestState)
        return nil;
    
    return @{ bestModel : bestState };
}

@end
