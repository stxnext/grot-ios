//
//  SNFieldReaction.h
//  Grot
//
//  Created by Dawid Żakowski on 15/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNFieldTransition.h"

@class SNGameState;

@interface SNFieldReaction : NSObject

@property (nonatomic, strong) SNGameState* targetState;
@property (nonatomic, strong) NSArray* fieldTransitions;

- (SNFieldTransition*)popTransition;

@end
