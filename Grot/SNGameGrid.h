//
//  SNGameGrid.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGrid.h"
#import "SNArrowField.h"
#import "SNGameResults.h"

@interface SNGameGrid : SNGrid

- (SNArrowField*)fieldPointedByField:(SNArrowField*)field;
- (CGPoint)positionPointedByField:(SNArrowField*)field;
- (void)fillWithRandomItems;
- (void)fillWithUnknownItems;
- (void)resolveUnknownItems;
- (NSArray*)sortedArrayFields:(NSArray*)fields;
- (NSComparator)arrayFieldComparator;

@end
