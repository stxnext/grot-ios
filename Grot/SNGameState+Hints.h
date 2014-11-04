//
//  SNGameState+Hints.h
//  Grot
//
//  Created by Dawid Żakowski on 07/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGameState.h"

@interface SNGameState (Hints)

- (NSDictionary*)transitions;
- (NSDictionary*)transitionOptimizedForStatePropertyAtKeyPath:(NSString*)keyPath treeDepth:(NSInteger)depth;
- (NSDictionary*)transitionOptimizedForMaxScoreWithTreeDepth:(NSInteger)depth;
- (NSDictionary*)transitionOptimizedForMaxMovesWithTreeDepth:(NSInteger)depth;
- (NSDictionary*)transitionOptimizedForBestMovesBeforeScoreWithTreeDepth:(NSInteger)depth;

@end
