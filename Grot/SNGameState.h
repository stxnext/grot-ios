//
//  SNGameState.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNGameGrid.h"
#import "SNGameResults.h"
#import "SNArrowField.h"
#import "SNFieldReaction.h"

@interface SNGameState : NSObject<NSCopying>

@property (nonatomic, strong) SNGameGrid* grid;
@property (nonatomic, strong) SNGameResults* results;
@property (nonatomic, strong) SNFieldReaction* scheduledReaction;

- (SNFieldReaction*)scheduleReactionAtField:(SNArrowField*)field;

@end
