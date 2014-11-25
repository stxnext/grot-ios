//
//  SNGrid.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGrid.h"
#import "SNPair.h"

CGPoint const SNGridInvalidPoint = (CGPoint){ -1.0, -1.0 };

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

- (NSArray*)allObjects
{
    return _items.allValues;
}

- (id)copyWithZone:(NSZone *)zone
{
    NSMutableDictionary* newItems = _items.mutableCopy;
    
    return [[self.class alloc] initWithSize:self.size items:newItems];
}

- (id)objectAtPoint:(CGPoint)point
{
    id<NSCopying> key = [NSValue valueWithCGPoint:point];
    return _items[key];
}

- (CGPoint)pointForObject:(id)object
{
    CGPoint point = SNGridInvalidPoint;
    
    for (NSValue* key in _items.allKeys)
    {
        NSObject* value = _items[key];
        
        if ([value isEqual:object])
        {
            point = [key CGPointValue];
            break;
        }
    }
    
    return point;
}

- (void)setObject:(id)object atPoint:(CGPoint)point
{
    id<NSCopying> key = [NSValue valueWithCGPoint:point];
    
    if (object)
        _items[key] = object;
    else
        [_items removeObjectForKey:key];
}

- (void)swapObjectAtPoint:(CGPoint)sourcePoint withObjectAtPoint:(CGPoint)targetPoint
{
    id sourceObject = [self objectAtPoint:sourcePoint];
    id targetObject = [self objectAtPoint:targetPoint];
    
    [self setObject:sourceObject atPoint:targetPoint];
    [self setObject:targetObject atPoint:sourcePoint];
}

- (void)fillWithItems:(NSArray*)items
{
    for (NSInteger y = 0; y < self.size.height; y++)
    {
        for (NSInteger x = 0; x < self.size.width; x++)
        {
            CGPoint point = (CGPoint){ x, y };
            
            if (![self objectAtPoint:point])
            {
                NSUInteger i = point.x + point.y * self.size.width;
                id object = items[i];
                [self setObject:object atPoint:point];
            }
        }
    }
}

- (void)pushDown
{
    for (NSInteger x = 0; x < self.size.width; x++)
    {
        NSUInteger gaps = 0;
        
        for (NSInteger y = self.size.height - 1; y >= 0; y--)
        {
            CGPoint point = (CGPoint){ x, y };
            
            if (![self objectAtPoint:point])
            {
                gaps++;
            }
            else if (gaps > 0)
            {
                CGPoint swapPoint = (CGPoint){ x, y + gaps };
                [self swapObjectAtPoint:point withObjectAtPoint:swapPoint];
            }
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

- (BOOL)containsPoint:(CGPoint)point;
{
    return point.x >= 0 && point.y >= 0 && point.x < self.size.width && point.y < self.size.height;
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

- (SNGrid*)gridBySubtractingGrid:(SNGrid*)grid
{
    NSAssert(CGSizeEqualToSize(self.size, grid.size), @"Grid sizes equality test failed.");
    
    SNGrid* resultGrid = [SNGrid.alloc initWithSize:self.size];
    
    for (NSInteger x = 0; x < self.size.width; x++)
    {
        for (NSInteger y = self.size.height - 1; y >= 0; y--)
        {
            CGPoint point = (CGPoint){ x, y };
            
            id obj1 = [self objectAtPoint:point];
            id obj2 = [grid objectAtPoint:point];
            
            BOOL isEmptyToFull = !obj1 && obj2;
            BOOL isFullOldToFullNew = obj1 && obj2 && ![obj1 isEqual:obj2];
            
            if (isEmptyToFull || isFullOldToFullNew)
            {
                [resultGrid setObject:obj2 atPoint:point];
            }
        }
    }
    
    return resultGrid;
}

#pragma mark - Object overrides

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

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class])
        return [super isEqual:object];
    
    NSObject* other = object;
    return self.hash == other.hash;
}

- (NSUInteger)hash
{
    NSUInteger aggregate = SNPair_Szudzik(self.size.width, self.size.height);
    
    for (NSObject* item in _items)
        aggregate = SNPair_Szudzik(aggregate, item.hash);
    
    return aggregate;
}

@end
