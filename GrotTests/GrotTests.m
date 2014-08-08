//
//  GrotTests.m
//  GrotTests
//
//  Created by Dawid Żakowski on 16/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SNGrotHints.h"

@interface GrotTests : XCTestCase
@end

@implementation GrotTests

#pragma mark - Config

static CGSize BoardSize = (CGSize){ 4, 4 };
static NSUInteger InitialMovesCount = 5;
static NSUInteger GamesCount = 1000;

#pragma mark - Tests

+ (NSArray*)mostOptimalGridItems
{
    return @[ [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionRight],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionRight],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionRight],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionDown],
              
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionRight],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionRight],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionDown],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionDown],
              
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionUp],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionUp],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionLeft],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionDown],
              
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionUp],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionLeft],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionLeft],
              [SNGrotFieldModel modelWithColorType:kColor4 direction:SNFieldDirectionLeft],
              ];
}

- (void)testSingleGameplayWithMostOptimalFills
{
    SNGameState* state = SNGameState.new;
    state.grid = [[SNGrotGrid alloc] initWithSize:BoardSize];
    state.results = SNGameResults.zeroResults;
    
    for (state.results.moves = InitialMovesCount; state.results.moves > 0; state.results.moves--)
    {
        [state.grid fillWithItems:self.class.mostOptimalGridItems];
        CGPoint point = (CGPoint){ 0, 0 };
        SNGrotFieldModel* grot = [state.grid objectAtPoint:point];
        SNGameResults* gainedResults = [state.grid runReactionAtGrot:grot gameResults:state.results];
        [state.results add:gainedResults];
        [state.grid pushDown];
        
        NSLog(@"Results: %@", state.results);
    }
    
    XCTAssertEqual(state.results.score, 6912, @"Failure");
}

- (void)testSingleGameplayWithRandomFills
{
    SNGameState* state = SNGameState.new;
    state.grid = [[SNGrotGrid alloc] initWithSize:BoardSize];
    state.results = SNGameResults.zeroResults;
    
    for (state.results.moves = 5; state.results.moves > 0; state.results.moves--)
    {
        [state.grid fillWithRandoms];
        CGPoint point = (CGPoint){ 0, 0 };
        SNGrotFieldModel* grot = [state.grid objectAtPoint:point];
        SNGameResults* gainedResults = [state.grid runReactionAtGrot:grot gameResults:state.results];
        [state.results add:gainedResults];
        [state.grid pushDown];
        
        NSLog(@"Results: %@", state.results);
    }
}

- (void)testSingleMoveOptimizedForMaxScoreWithMostOptimalFills
{
    SNGameState* state = SNGameState.new;
    state.grid = [[SNGrotGrid alloc] initWithSize:BoardSize];
    state.results = SNGameResults.zeroResults;
    state.results.moves = 5;
    [state.grid fillWithItems:self.class.mostOptimalGridItems];
    SNGrotFieldModel* bestModel = state.generatedStateOptimizedForMaxScore.allKeys.firstObject;
    SNGameResults* finalResults = [state.grid runReactionAtGrot:bestModel gameResults:state.results];
    
    XCTAssertEqual(finalResults.score, 384, @"Failure");
}

- (void)testSingleMoveOptimizedForMaxScoreWithRandomFills
{
    SNGameState* state = SNGameState.new;
    state.grid = [[SNGrotGrid alloc] initWithSize:BoardSize];
    state.results = SNGameResults.zeroResults;
    state.results.moves = 5;
    [state.grid fillWithRandoms];
    SNGrotFieldModel* bestModel = state.generatedStateOptimizedForMaxScore.allKeys.firstObject;
    SNGameResults* finalResults = [state.grid runReactionAtGrot:bestModel gameResults:state.results];
    
    NSLog(@"Results: %@", finalResults);
}

- (void)testMultipleGameplaysOptimizedForMaxScoreWithRandomFills
{
    NSInteger bestScore = -1;
    
    for (NSUInteger i = 0; i < GamesCount; i++)
    {
        SNGameState* state = SNGameState.new;
        state.grid = [[SNGrotGrid alloc] initWithSize:BoardSize];
        state.results = SNGameResults.zeroResults;
        state.results.moves = 5;
        
        for (state.results.moves = 5; state.results.moves > 0; state.results.moves--)
        {
            [state.grid fillWithRandoms];
            SNGrotFieldModel* bestModel = state.generatedStateOptimizedForMaxScore.allKeys.firstObject;
            SNGameResults* gainedResults = [state.grid runReactionAtGrot:bestModel gameResults:state.results];
            [state.results add:gainedResults];
            [state.grid pushDown];
        }
        
        bestScore = MAX(bestScore, state.results.score);
        
        if (bestScore == state.results.score)
            NSLog(@"Best score (received at move #%d): %d", i, bestScore);
    }
}

@end
