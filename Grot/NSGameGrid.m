//
//  NSGameGrid.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSGameGrid.h"

@implementation NSGameGrid

#pragma mark - Field filtering

- (NSArrowField*)fieldPointedByField:(NSArrowField*)field
{
    CGPoint position = [self positionPointedByField:field];
    return [self objectAtPoint:position];
}

- (CGPoint)positionPointedByField:(NSArrowField*)field
{
    for (CGPoint nextPosition, position = nextPosition = [self pointForObject:field]; true; position = nextPosition)
    {
        switch (field.direction)
        {
            case NSFieldDirectionUp: nextPosition.y -= 1; break;
            case NSFieldDirectionLeft: nextPosition.x -= 1; break;
            case NSFieldDirectionDown: nextPosition.y += 1; break;
            case NSFieldDirectionRight: nextPosition.x += 1; break;
            case NSFieldDirectionsCount: @throw @"Enumeration exception";
        }
        
        NSArrowField* nextModel = [self objectAtPoint:nextPosition];
        
        if (nextModel) // optionaly nextModel.isAvailable
            return nextPosition;
        
        if (![self containsPoint:nextPosition])
            return position;
    }
}

#pragma mark - Container filling

+ (NSArray*)unknownItemsWithCount:(NSInteger)count
{
    NSMutableArray* mutableItems = NSMutableArray.array;
    
    for (int i = 0; i < count; i++)
    {
        NSArrowField* field = [NSArrowField unknownModel];
        [mutableItems addObject:field];
    }
    
    return mutableItems;
}

- (void)fillWithRandomItems
{
    [self fillWithUnknownItems];
    [self resolveUnknownItems];
}

- (void)fillWithUnknownItems
{
    NSArray* items = [self.class unknownItemsWithCount:self.area];
    [self fillWithItems:items];
}

- (void)resolveUnknownItems
{
    for (NSInteger y = 0; y < self.size.height; y++)
    {
        for (NSInteger x = 0; x < self.size.width; x++)
        {
            CGPoint point = (CGPoint){ x, y };
            NSArrowField* field = [self objectAtPoint:point];
            [field resolveUnknown];
        }
    }
}

#pragma mark - Sorting

- (NSArray*)sortedArrayFields:(NSArray*)fields
{
    return [fields sortedArrayUsingComparator:[self arrayFieldComparator]];
}

- (NSComparator)arrayFieldComparator
{
    return ^NSComparisonResult(NSArrowField* obj1, NSArrowField* obj2) {
        CGFloat distance1 = [self pointForObject:obj1].y * self.size.width + [self pointForObject:obj1].x;
        CGFloat distance2 = [self pointForObject:obj2].y * self.size.width + [self pointForObject:obj2].x;
        
        if (distance1 < distance2)
            return NSOrderedAscending;
        else if (distance1 == distance2)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    };
}

@end
