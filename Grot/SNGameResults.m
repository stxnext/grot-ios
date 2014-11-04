//
//  SNGameResults.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGameResults.h"
#import "SNPair.h"

@implementation SNGameResults

+ (SNGameResults*)unknownResults
{
    SNGameResults* results = SNGameResults.new;
    results.score = -1;
    results.moves = -1;
    
    return results;
}

+ (SNGameResults*)zeroResults
{
    SNGameResults* results = SNGameResults.new;
    results.score = 0;
    results.moves = 0;
    
    return results;
}

- (void)add:(SNGameResults*)results
{
    self.score += results.score;
    self.moves += results.moves;
}

- (id)copyWithZone:(NSZone *)zone
{
    SNGameResults* copy = SNGameResults.new;
    copy.score = self.score;
    copy.moves = self.moves;
    
    return copy;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"(%ld; %ld)", (long)self.score, (long)self.moves];
}

#pragma mark - Object equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class])
        return [super isEqual:object];
    
    NSObject* other = object;
    return self.hash == other.hash;
}

- (NSUInteger)hash
{
    return SNPair_Szudzik(self.score, self.moves);
}

@end
