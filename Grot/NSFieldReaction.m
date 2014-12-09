//
//  NSFieldReaction.m
//  Grot
//
//  Created by Dawid Żakowski on 15/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSFieldReaction.h"
#import "NSGameState.h"
#import "NSPair.h"

@implementation NSFieldReaction

- (NSFieldTransition*)popTransition
{
    if (self.fieldTransitions.count == 0)
        return nil;
    
    NSFieldTransition* topTransition = self.fieldTransitions.firstObject;
    NSMutableArray* transitions = self.fieldTransitions.mutableCopy;
    [transitions removeObjectAtIndex:0];
    self.fieldTransitions = transitions;
    
    return topTransition;
}

#pragma mark - Object overrides

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@", self.fieldTransitions];
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
    NSUInteger aggregate = self.targetState.hash;
    
    for (NSFieldTransition* transition in self.fieldTransitions)
        aggregate = NSPair_Szudzik(aggregate, transition.hash);
    
    return aggregate;
}

@end
