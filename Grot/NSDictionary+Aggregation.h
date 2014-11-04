//
//  NSDictionary+Aggregation.h
//  Grot
//
//  Created by Dawid Żakowski on 07/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Aggregation)

- (id)keyForMaxValueUsingValueComparator:(NSComparator)comparator;

@end
