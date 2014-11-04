//
//  SNArrowField.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNArrowField.h"
#import "NSNumber+Math.h"
#import "UIColor+Parser.h"

@implementation SNArrowField

#pragma mark Static constructors

+ (instancetype)modelWithType:(SNArrowFieldType)type direction:(SNArrowFieldDirection)direction
{
    SNArrowField* model = self.class.new;
    [model setType:type direction:direction];
    
    return model;
}

+ (instancetype)unknownModel
{
    SNArrowField* model = self.class.new;
    
    return model;
}

+ (instancetype)randomModel
{
    SNArrowField* model = self.class.new;
    [model randomizeValues];
    
    return model;
}

#pragma mark - Init and copy

- (instancetype)init
{
    self = super.init;
    
    _unknown = YES;
    _isAvailable = YES;
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SNArrowField* copy = [self.class modelWithType:self.type direction:self.direction];
    copy.isAvailable = self.isAvailable;
    
    return copy;
}

#pragma mark - Setters

- (void)setType:(SNArrowFieldType)type direction:(SNArrowFieldDirection)direction
{
    _type = type;
    _direction = direction;
    _unknown = NO;
}

- (void)randomizeValues
{
    [self setType:self.class.randomType direction:arc4random_uniform(SNFieldDirectionsCount)];
}

- (BOOL)resolveUnknown
{
    if (!self.isUnknown)
        return NO;
    
    [self randomizeValues];
    
    return YES;
}

#pragma mark - Indirect properties

- (NSInteger)value
{
    return [self.class.points[@(_type)] integerValue];
}

- (double)angle
{
    return [self.class.angles[@(_direction)] doubleValue];
}

#pragma mark - Type distribution

+ (SNArrowFieldType)randomType
{
    const int randomAccuracy = 100000;
    double randomValue = (double)arc4random_uniform(randomAccuracy) / (double)randomAccuracy;
    
    double counter = 0.0;
    
    for (SNArrowFieldType type = 0; type < SNArrowFieldTypesCount; type ++)
    {
        double distributionValue = [self.class.typeDistribution[@(type)] doubleValue];
        counter += distributionValue;
        
        if (randomValue <= counter)
            return type;
    }
    
    return SNArrowFieldTypesCount - 1;
}

+ (NSDictionary*)typeDistribution
{
    return @{ @(SNArrowFieldTypeLowest)  : @(0.4),
              @(SNArrowFieldTypeLow)     : @(0.3),
              @(SNArrowFieldTypeeHigh)   : @(0.2),
              @(SNArrowFieldTypeHighest) : @(0.1) };
}

#pragma mark - Default config

+ (NSDictionary*)points
{
    return @{ @(SNArrowFieldTypeLowest)  : @(1),
              @(SNArrowFieldTypeLow)     : @(2),
              @(SNArrowFieldTypeeHigh)   : @(3),
              @(SNArrowFieldTypeHighest) : @(4) };
}

+ (NSDictionary*)angles
{
    return @{ @(SNFieldDirectionUp)    : @(M_PI_2),
              @(SNFieldDirectionLeft)  : @(M_PI),
              @(SNFieldDirectionDown)  : @(M_PI * 1.5),
              @(SNFieldDirectionRight) : @(0.0) };
}

#pragma mark - Object overrides

- (NSString *)description
{
    NSString* arrowString
    = _direction == SNFieldDirectionUp    ? @"^"
    : _direction == SNFieldDirectionRight ? @">"
    : _direction == SNFieldDirectionDown  ? @"V"
    : _direction == SNFieldDirectionLeft  ? @"<"
    : @"?";
    
    return arrowString;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class])
        return [super isEqual:object];
    
    typeof(self) other = object;
    return self == other;
}

- (NSUInteger)hash
{
    return (NSUInteger)(&self);
}

@end
