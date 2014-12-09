//
//  NSGameState.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSGameGrid.h"
#import "NSGameResults.h"
#import "NSArrowField.h"
#import "NSFieldReaction.h"

@interface NSGameState : NSObject<NSCopying>

@property (nonatomic, strong) NSGameGrid* grid;
@property (nonatomic, strong) NSGameResults* results;
@property (nonatomic, strong) NSFieldReaction* scheduledReaction;

- (NSGameState*)fallenState;
- (NSGameState*)filledState;
- (NSGameState*)resolvedState;
- (NSGameState*)stateWithReactionPenalty;
- (NSFieldReaction*)scheduleReactionAtField:(NSArrowField*)field;

@end
