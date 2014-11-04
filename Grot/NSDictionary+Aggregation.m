//
//  NSDictionary+Aggregation.m
//  Grot
//
//  Created by Dawid Żakowski on 07/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSDictionary+Aggregation.h"

@implementation NSDictionary (Aggregation)

- (id)keyForMaxValueUsingValueComparator:(NSComparator)comparator
{
    id keyForMaxValue = self.allKeys.firstObject;
    
    for (id key in self.allKeys)
    {
        NSComparisonResult result = comparator(self[key], self[keyForMaxValue]);
        
        if (result == NSOrderedDescending)
            keyForMaxValue = key;
    }
    
    return keyForMaxValue;
}

@end
