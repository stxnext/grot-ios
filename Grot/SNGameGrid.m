//
//  SNGameGrid.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGameGrid.h"

@implementation SNGameGrid

#pragma mark - Field filtering

- (SNArrowField*)fieldPointedByField:(SNArrowField*)field
{
    CGPoint position = [self positionPointedByField:field];
    return [self objectAtPoint:position];
}

- (CGPoint)positionPointedByField:(SNArrowField*)field
{
    for (CGPoint nextPosition, position = nextPosition = [self pointForObject:field]; true; position = nextPosition)
    {
        switch (field.direction)
        {
            case SNFieldDirectionUp: nextPosition.y -= 1; break;
            case SNFieldDirectionLeft: nextPosition.x -= 1; break;
            case SNFieldDirectionDown: nextPosition.y += 1; break;
            case SNFieldDirectionRight: nextPosition.x += 1; break;
            case SNFieldDirectionsCount: @throw @"Enumeration exception";
        }
        
        SNArrowField* nextModel = [self objectAtPoint:nextPosition];
        
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
        SNArrowField* field = [SNArrowField unknownModel];
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
            SNArrowField* field = [self objectAtPoint:point];
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
    return ^NSComparisonResult(SNArrowField* obj1, SNArrowField* obj2) {
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
