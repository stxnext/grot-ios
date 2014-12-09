//
//  NSGameGrid.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSGrid.h"
#import "NSArrowField.h"
#import "NSGameResults.h"

@interface NSGameGrid : NSGrid

- (NSArrowField*)fieldPointedByField:(NSArrowField*)field;
- (CGPoint)positionPointedByField:(NSArrowField*)field;
- (void)fillWithRandomItems;
- (void)fillWithUnknownItems;
- (void)resolveUnknownItems;
- (NSArray*)sortedArrayFields:(NSArray*)fields;
- (NSComparator)arrayFieldComparator;

@end
