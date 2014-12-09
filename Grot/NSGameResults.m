//
//  NSGameResults.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSGameResults.h"
#import "NSPair.h"

@implementation NSGameResults

+ (NSGameResults*)unknownResults
{
    NSGameResults* results = NSGameResults.new;
    results.score = -1;
    results.moves = -1;
    
    return results;
}

+ (NSGameResults*)zeroResults
{
    NSGameResults* results = NSGameResults.new;
    results.score = 0;
    results.moves = 0;
    
    return results;
}

- (void)add:(NSGameResults*)results
{
    self.score += results.score;
    self.moves += results.moves;
}

- (void)subtract:(NSGameResults*)results
{
    self.score -= results.score;
    self.moves -= results.moves;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSGameResults* copy = NSGameResults.new;
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
    return NSPair_Szudzik(self.score, self.moves);
}

@end
