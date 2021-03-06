//
//  NSGameState.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSGameState.h"
#import "NSPair.h"
#import "NSFieldTransition.h"

@implementation NSGameState

#pragma mark - Init and copy

- (id)copyWithZone:(NSZone*)zone
{
    NSGameState* copy = NSGameState.new;
    copy.grid = self.grid.copy;
    copy.results = self.results.copy;
    
    return copy;
}

#pragma mark - Game logic

- (NSGameState*)fallenState
{
    NSGameState* state = self.copy;
    [state.grid pushDown];
    
    return state;
}

- (NSGameState*)filledState
{
    NSGameState* state = [self fallenState];
    [state.grid fillWithUnknownItems];
    
    return state;
}

- (NSGameState*)resolvedState
{
    NSGameState* state = [self filledState];
    [state.grid resolveUnknownItems];
    
    return state;
}

- (NSGameState*)stateWithReactionPenalty
{
    NSGameResults* penaltyResults = [NSGameResults new];
    penaltyResults.moves = -1;
    
    NSGameState* state = self.copy;
    [state.results add:penaltyResults];
    
    return state;
}

- (NSFieldReaction*)scheduleReactionAtField:(NSArrowField*)field
{
    NSFieldReaction* reaction = NSFieldReaction.new;
    reaction.targetState = self.copy;
    reaction.targetState.scheduledReaction = nil;
    
    NSMutableArray* transitions = NSMutableArray.array;
    
    for (CGPoint nextPosition, position = [self.grid pointForObject:field]; ; position = nextPosition)
    {
        NSArrowField* arrowField = [reaction.targetState.grid objectAtPoint:position];
        
        if (!arrowField)
            break;
        
        if (arrowField.isUnknown)
        {
            reaction.targetState.results = NSGameResults.unknownResults;
            break;
        }
        
        nextPosition = [reaction.targetState.grid positionPointedByField:arrowField];
        [reaction.targetState.grid setObject:nil atPoint:position];
        
        NSFieldTransition* transition = NSFieldTransition.new;
        transition.arrowField = arrowField;
        transition.endpointPosition = nextPosition;
        [transitions addObject:transition];
    }
    
    reaction.fieldTransitions = transitions;
    
    if (![reaction.targetState.results isEqual:NSGameResults.unknownResults])
    {
        NSGameResults* gainedResults = [self resultsForReaction:reaction];
        [reaction.targetState.results add:gainedResults];
    }
    
    return self.scheduledReaction = reaction;
}

- (NSGameResults*)resultsForReaction:(NSFieldReaction*)reaction
{
    NSGameResults* gainedResults = NSGameResults.zeroResults;
    NSInteger chainLength = reaction.fieldTransitions.count;
    NSGameResults* currentResults = self.results;
    
    for (NSFieldTransition* transition in reaction.fieldTransitions)
    {
        gainedResults.score += transition.arrowField.value;
    }
    
    for (NSInteger row = 0; row < reaction.targetState.grid.size.height; row++)
    {
        if ([reaction.targetState.grid isEmptyRow:row])
            gainedResults.score += reaction.targetState.grid.size.width * 10;
    }
    
    for (NSInteger column = 0; column < reaction.targetState.grid.size.width; column++)
    {
        if ([reaction.targetState.grid isEmptyColumn:column])
            gainedResults.score += reaction.targetState.grid.size.height * 10;
    }
    
    NSInteger threshold = floor((gainedResults.score + currentResults.score) / (5 * reaction.targetState.grid.area)) + reaction.targetState.grid.longerSideLength - 1;
    gainedResults.moves = MAX(0, chainLength - threshold);
    
    return gainedResults;
}

#pragma mark - Object overrides

- (NSString*)description
{
    return [NSString stringWithFormat:@"(%@; %@)", self.grid, self.results];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class])
        return [super isEqual:object];
    
    NSObject* other = object;
    return self.hash == other.hash;
}

- (NSUInteger)hash
{
    return NSPair_Szudzik(self.grid.hash, self.results.hash);
}

@end
