//
//  SNGrotHints.m
//  Grot
//
//  Created by Dawid Żakowski on 06/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGrotHints.h"

@implementation NSDictionary (Aggregation)

- (id)keyForMaxValueUsingValueComparator:(NSComparator)comparator
{
    id keyForMaxValue = nil;
    
    for (id key in self.allKeys)
    {
        NSComparisonResult result = comparator(self[key], self[keyForMaxValue]);
        
        if (result != NSOrderedAscending)
            keyForMaxValue = key;
    }
    
    return keyForMaxValue;
}

@end

@implementation SNGameResults

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
    return [NSString stringWithFormat:@"(%d; %d)", self.score, self.moves];
}

@end

@implementation SNGrid

- (instancetype)initWithSize:(CGSize)size items:(NSMutableDictionary*)items
{
    self = [super init];
    
    if (self)
    {
        _items = items;
        _size = size;
    }
    
    return self;
}

- (instancetype)initWithSize:(CGSize)size
{
    return [self initWithSize:size items:NSMutableDictionary.dictionary];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSMutableDictionary* newItems = _items.mutableCopy;
    
    for (id key in newItems.allKeys)
        newItems[key] = [newItems[key] copy];
    
    return [[self.class alloc] initWithSize:self.size items:newItems];
}

- (id)objectAtPoint:(CGPoint)point
{
    id<NSCopying> key = [NSValue valueWithCGPoint:point];
    return _items[key];
}

- (void)setObject:(id)object atPoint:(CGPoint)point
{
    id<NSCopying> key = [NSValue valueWithCGPoint:point];
    
    if (object)
        _items[key] = object;
    else
        [_items removeObjectForKey:key];
}

- (void)pushDown
{
    for (NSInteger y = 0; y < self.size.height; y++)
    for (NSInteger x = 0; x < self.size.width; x++)
    {
        CGPoint upPoint = (CGPoint){ x, y };
        CGPoint downPoint = (CGPoint){ x, y + 1 };
            
        if ([self objectAtPoint:upPoint] && ![self objectAtPoint:downPoint])
        {
            id upObject = [self objectAtPoint:upPoint];
            [self setObject:upObject atPoint:downPoint];
            [self setObject:nil atPoint:upPoint];
        }
    }
}

- (BOOL)isEmptyRow:(NSInteger)row
{
    for (NSInteger x = 0; x < self.size.width; x++)
    {
        CGPoint point = (CGPoint){ x, row };
        
        if ([self objectAtPoint:point])
            return NO;
    }
    
    return YES;
}

- (BOOL)isEmptyColumn:(NSInteger)column
{
    for (NSInteger y = 0; y < self.size.height; y++)
    {
        CGPoint point = (CGPoint){ column, y };
        
        if ([self objectAtPoint:point])
            return NO;
    }
    
    return YES;
}

- (NSInteger)longerSideLength
{
    return MAX(self.size.width, self.size.height);
}

- (NSInteger)shorterSideLength
{
    return MIN(self.size.width, self.size.height);
}

- (NSInteger)area
{
    return self.size.width * self.size.height;
}

- (BOOL)containsPoint:(CGPoint)point;
{
    return point.x >= 0 && point.y >= 0 && point.x < self.size.width && point.y < self.size.height;
}

- (NSString*)description
{
    NSMutableString* description = [NSMutableString string];
    
    for (NSInteger y = 0; y < self.size.height; y++)
    {
        for (NSInteger x = 0; x < self.size.height; x++)
        {
            CGPoint point = (CGPoint){ x, y };
            id object = [self objectAtPoint:point];
            NSString* objectDescription = object ? [object description] : @" ";
            
            [description appendFormat:@"%@\t", objectDescription];
        }
        
        [description appendString:@"\n"];
    }
    
    return description;
}

@end

@implementation SNGrotGrid

- (void)setObject:(id)object atPoint:(CGPoint)point
{
    [super setObject:object atPoint:point];
    
    if ([object isKindOfClass:SNGrotFieldModel.class])
    {
        SNGrotFieldModel* model = object;
        model.position = point;
    }
}

- (SNGrotFieldModel*)grotPointedByGrot:(SNGrotFieldModel*)grot
{
    for (CGPoint nextPosition, position = nextPosition = grot.position; true; position = nextPosition)
    {
        switch (grot.direction)
        {
            case SNFieldDirectionUp: nextPosition.y -= 1; break;
            case SNFieldDirectionLeft: nextPosition.x -= 1; break;
            case SNFieldDirectionDown: nextPosition.y += 1; break;
            case SNFieldDirectionRight: nextPosition.x += 1; break;
        }
        
        SNGrotFieldModel* nextModel = [self objectAtPoint:nextPosition];
        
        if (nextModel) // optionaly nextModel.isAvailable
            return nextModel;
        
        if (![self containsPoint:nextPosition])
            return nil;
    }
}

- (SNGameResults*)runReactionAtGrot:(SNGrotFieldModel*)grot gameResults:(SNGameResults*)currentResults
{
    SNGameResults* gainedResults = SNGameResults.zeroResults;
    NSInteger chainLength = 0;
    
    for (SNGrotFieldModel* node = grot; node != nil; node = [self grotPointedByGrot:node])
    {
        chainLength++;
        gainedResults.score += node.value;
        [self setObject:nil atPoint:node.position]; // optionaly node.enabled = NO;
    }
    
    for (NSInteger row = 0; row < self.size.height; row++)
        if ([self isEmptyRow:row])
            gainedResults.score += self.size.width * 10;
    
    for (NSInteger column = 0; column < self.size.width; column++)
        if ([self isEmptyColumn:column])
            gainedResults.score += self.size.height * 10;
    
    NSInteger threshold = floor((gainedResults.score + currentResults.score) / (5 * self.area)) + self.longerSideLength - 1;
    gainedResults.moves = MAX(0, chainLength - threshold);
    
    return gainedResults;
}

- (void)fillWithRandoms
{
    for (NSInteger y = 0; y < self.size.height; y++)
    for (NSInteger x = 0; x < self.size.width; x++)
    {
        CGPoint point = (CGPoint){ x, y };
        
        if (![self objectAtPoint:point])
        {
            SNGrotFieldModel* newObject = SNGrotFieldModel.randomModel;
            [self setObject:newObject atPoint:point];
        }
    }
}

- (void)fillWithItems:(NSArray*)items
{
    NSInteger iterator = 0;
    
    for (NSInteger y = 0; y < self.size.height; y++)
    for (NSInteger x = 0; x < self.size.width; x++)
    {
        CGPoint point = (CGPoint){ x, y };
        
        if (![self objectAtPoint:point])
        {
            id object = items[iterator++];
            [self setObject:object atPoint:point];
        }
    }
}

@end

@implementation SNGameState

- (NSDictionary*)generatedStates
{
    __block NSMutableDictionary* results = NSMutableDictionary.dictionary;
    
    for (NSInteger y = 0; y < self.grid.size.height; y++)
    for (NSInteger x = 0; x < self.grid.size.width; x++)
    {
        CGPoint point = (CGPoint){ x, y };
        SNGrotFieldModel* baseModel = [self.grid objectAtPoint:point];
        
        if (baseModel)
        {
            SNGameState* state = SNGameState.new;
            state.grid = self.grid.copy;
            state.results = self.results.copy;
            state.results.moves--;
            
            SNGrotFieldModel* copyModel = [state.grid objectAtPoint:point];
            SNGameResults* gainedResults = [state.grid runReactionAtGrot:copyModel gameResults:state.results];
            [state.results add:gainedResults];
            
            results[baseModel] = state;
        }
    }
    
    return results;
}

- (NSDictionary*)generatedStateOptimizedForStatePropertyAtKeyPath:(NSString*)keyPath
{
    NSDictionary* generatedStates = self.generatedStates;
    
    SNGrotFieldModel* bestModel = [generatedStates keyForMaxValueUsingValueComparator:^NSComparisonResult(SNGameState* state1, SNGameState* state2) {
        NSInteger value1 = [[state1 valueForKeyPath:keyPath] integerValue];
        NSInteger value2 = [[state2 valueForKeyPath:keyPath] integerValue];
        
        if (value1 < value2)
            return NSOrderedAscending;
        else if (value1 == value2)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
    
    SNGameState* bestState = generatedStates[bestModel];
    
    return @{ bestModel : bestState };
}

- (NSDictionary*)generatedStateOptimizedForMaxScore
{
    return [self generatedStateOptimizedForStatePropertyAtKeyPath:@"results.score"];
}

- (NSDictionary*)generatedStateOptimizedForMaxMoves
{
    return [self generatedStateOptimizedForStatePropertyAtKeyPath:@"results.moves"];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"(%@; %@)", self.grid, self.results];
}

@end
