//
//  SNGameState+Hints.m
//  Grot
//
//  Created by Dawid Żakowski on 07/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGameState+Hints.h"
#import "SNArrowField.h"
#import "NSDictionary+Aggregation.h"

@implementation SNGameState (Hints)

- (NSDictionary*)transitions
{
    NSMutableDictionary* results = NSMutableDictionary.dictionary;
    
    for (NSInteger y = 0; y < self.grid.size.height; y++)
    {
        for (NSInteger x = 0; x < self.grid.size.width; x++)
        {
            CGPoint point = (CGPoint){ x, y };
            SNArrowField* field = [self.grid objectAtPoint:point];
            
            if (field && !field.isUnknown)
            {
                SNGameState* state = self.copy;
                SNArrowField* copyModel = [state.grid objectAtPoint:point];
                SNFieldReaction* reaction = [state scheduleReactionAtField:copyModel];
                SNGameResults* newResults = reaction.targetState.results;
                
                if (![newResults isEqual:SNGameResults.unknownResults])
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
        
        for (SNArrowField* field in initialTransitions.allKeys)
        {
            SNGameState* state = initialTransitions[field];
            NSDictionary* transition = [state transitionOptimizedForStatePropertyAtKeyPath:keyPath treeDepth:depth - 1];
            
            if (!transition)
                continue;
            
            innerTransitions[field] = transition.allValues.firstObject;
        }
        
        if (innerTransitions.allKeys.count == 0)
            return nil;
        
        analyzedTransitions = innerTransitions;
    }
    
    SNArrowField* bestModel = [analyzedTransitions keyForMaxValueUsingValueComparator:^NSComparisonResult(SNGameState* state1, SNGameState* state2) {
        NSInteger value1 = [[state1 valueForKeyPath:keyPath] integerValue];
        NSInteger value2 = [[state2 valueForKeyPath:keyPath] integerValue];
        
        if (value1 < value2)
            return NSOrderedAscending;
        else if (value1 == value2)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
    
    SNGameState* bestState = analyzedTransitions[bestModel];
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
    SNGameState* bestMovesState = movesTransision.allValues.firstObject;
    SNArrowField* bestModel;
    SNGameState* bestState;
    
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
