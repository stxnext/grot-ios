//
//  NSFieldTransition.m
//  Grot
//
//  Created by Dawid Żakowski on 15/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSFieldTransition.h"
#import "NSPair.h"

@implementation NSFieldTransition

#pragma mark - Object overrides

- (NSString*)description
{
    return [NSString stringWithFormat:@"(%@, %@)", self.arrowField, NSStringFromCGPoint(self.endpointPosition)];
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
    return NSPair_Szudzik(self.arrowField.hash, NSPair_Szudzik(self.endpointPosition.x, self.endpointPosition.y));
}

@end
