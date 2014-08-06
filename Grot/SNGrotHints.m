//
//  SNGrotHints.m
//  Grot
//
//  Created by Dawid Żakowski on 06/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGrotHints.h"

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
    return [[self.class alloc] initWithSize:self.size items:_items.mutableCopy];
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
    for (NSUInteger x = 0; x < self.size.width; x++)
    for (NSUInteger y = 0; y < self.size.height; y++)
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

- (BOOL)isEmptyRow:(NSUInteger)row
{
    for (NSUInteger x = 0; x < self.size.width; x++)
    {
        CGPoint point = (CGPoint){ x, row };
        
        if ([self objectAtPoint:point])
            return NO;
    }
    
    return YES;
}

- (BOOL)isEmptyColumn:(NSUInteger)column
{
    for (NSUInteger y = 0; y < self.size.height; y++)
    {
        CGPoint point = (CGPoint){ column, y };
        
        if ([self objectAtPoint:point])
            return NO;
    }
    
    return YES;
}

- (NSUInteger)longerSideLength
{
    return MAX(self.size.width, self.size.height);
}

- (NSUInteger)shorterSideLength
{
    return MIN(self.size.width, self.size.height);
}

- (NSUInteger)area
{
    return self.size.width * self.size.height;
}

- (BOOL)containsPoint:(CGPoint)point;
{
    return point.x >= 0 && point.y >= 0 && point.x < self.size.width && point.y < self.size.height;
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

- (SNGameResults*)runGrot:(SNGrotFieldModel*)grot withGameResults:(SNGameResults*)currentResults
{
    SNGameResults* gainedResults = SNGameResults.zeroResults;
    NSUInteger chainLength = 0;
    
    for (SNGrotFieldModel* node = grot; node != nil; node = [self grotPointedByGrot:node])
    {
        chainLength++;
        gainedResults.score += node.value;
        [self setObject:nil atPoint:node.position]; // optionaly node.enabled = NO;
    }
    
    for (NSUInteger row = 0; row < self.size.height; row++)
        if ([self isEmptyRow:row])
            gainedResults.score += self.size.width * 10;
    
    for (NSUInteger column = 0; column < self.size.width; column++)
        if ([self isEmptyColumn:column])
            gainedResults.score += self.size.height * 10;
    
    NSUInteger threshold = floor((gainedResults.score + currentResults.score) / (5 * self.area)) + self.longerSideLength - 1;
    
    if (threshold <= chainLength)
        gainedResults.moves = chainLength - threshold;
    
    [self pushDown];
    [self fillHoles];
    
    return gainedResults;
}

- (void)fillHoles
{
    for (NSUInteger x = 0; x < self.size.width; x++)
    for (NSUInteger y = 0; y < self.size.height; y++)
    {
        CGPoint point = (CGPoint){ x, y };
        
        if (![self objectAtPoint:point])
        {
            SNGrotFieldModel* newObject = SNGrotFieldModel.randomModel;
            [self setObject:newObject atPoint:point];
        }
    }
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

@end

@implementation SNGrotHints

+ (void)test
{
    const NSUInteger squareSize = 4;
    
    SNGrotGrid* grid = [[SNGrotGrid alloc] initWithSize:CGSizeMake(squareSize, squareSize)];
    [grid fillHoles];
    
    SNGameResults* results = SNGameResults.zeroResults;
    CGPoint point = (CGPoint){ 0, 0 };
    SNGrotFieldModel* grot = [grid objectAtPoint:point];
    [grid runGrot:grot withGameResults:results];
}

@end
