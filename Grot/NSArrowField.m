//
//  NSArrowField.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSArrowField.h"
#import "NSNumber+Math.h"
#import "UIColor+Parser.h"

@implementation NSArrowField

#pragma mark Static constructors

+ (instancetype)modelWithType:(NSArrowFieldType)type direction:(NSArrowFieldDirection)direction
{
    NSArrowField* model = self.class.new;
    [model setType:type direction:direction];
    
    return model;
}

+ (instancetype)unknownModel
{
    NSArrowField* model = self.class.new;
    
    return model;
}

+ (instancetype)randomModel
{
    NSArrowField* model = self.class.new;
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
    NSArrowField* copy = [self.class modelWithType:self.type direction:self.direction];
    copy.isAvailable = self.isAvailable;
    
    return copy;
}

#pragma mark - Setters

- (void)setType:(NSArrowFieldType)type direction:(NSArrowFieldDirection)direction
{
    _type = type;
    _direction = direction;
    _unknown = NO;
}

- (void)randomizeValues
{
    [self setType:self.class.randomType direction:arc4random_uniform(NSFieldDirectionsCount)];
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

- (UIColor*)color
{
    return self.class.backgroundColors[@(_type)];
}

#pragma mark - Type distribution

+ (NSArrowFieldType)randomType
{
    const int randomAccuracy = 100000;
    double randomValue = (double)arc4random_uniform(randomAccuracy) / (double)randomAccuracy;
    
    double counter = 0.0;
    
    for (NSArrowFieldType type = 0; type < NSArrowFieldTypesCount; type ++)
    {
        double distributionValue = [self.class.typeDistribution[@(type)] doubleValue];
        counter += distributionValue;
        
        if (randomValue <= counter)
            return type;
    }
    
    return NSArrowFieldTypesCount - 1;
}

+ (NSDictionary*)typeDistribution
{
    return @{ @(NSArrowFieldTypeLowest)  : @(0.4),
              @(NSArrowFieldTypeLow)     : @(0.3),
              @(NSArrowFieldTypeeHigh)   : @(0.2),
              @(NSArrowFieldTypeHighest) : @(0.1) };
}

#pragma mark - Default config

+ (NSDictionary*)points
{
    return @{ @(NSArrowFieldTypeLowest)  : @(1),
              @(NSArrowFieldTypeLow)     : @(2),
              @(NSArrowFieldTypeeHigh)   : @(3),
              @(NSArrowFieldTypeHighest) : @(4) };
}

+ (NSDictionary*)angles
{
    return @{ @(NSFieldDirectionUp)    : @(M_PI_2),
              @(NSFieldDirectionLeft)  : @(M_PI),
              @(NSFieldDirectionDown)  : @(M_PI * 1.5),
              @(NSFieldDirectionRight) : @(0.0) };
}

+ (NSDictionary*)backgroundColors
{    return @{ @(NSArrowFieldTypeLowest)  : ColorFromHex(0x868788),
               @(NSArrowFieldTypeLow)     : ColorFromHex(0xFFEC00),
               @(NSArrowFieldTypeeHigh)   : ColorFromHex(0x8D198F),
               @(NSArrowFieldTypeHighest) : ColorFromHex(0X00968F) };
}

+ (UIColor*)arrowColor
{
    return ColorFromHex(0xFFFFFF);
}

#pragma mark - Object overrides

- (NSString *)description
{
    NSString* arrowString
    = _direction == NSFieldDirectionUp    ? @"^"
    : _direction == NSFieldDirectionRight ? @">"
    : _direction == NSFieldDirectionDown  ? @"V"
    : _direction == NSFieldDirectionLeft  ? @"<"
    : @"?";
    
    return arrowString;
}

@end
