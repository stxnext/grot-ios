//
//  NSFieldReaction.h
//  Grot
//
//  Created by Dawid Żakowski on 15/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFieldTransition.h"

@class NSGameState;

@interface NSFieldReaction : NSObject

@property (nonatomic, strong) NSGameState* targetState;
@property (nonatomic, strong) NSArray* fieldTransitions;

- (NSFieldTransition*)popTransition;

@end
