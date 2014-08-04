//
//  SNGrotFieldModel.m
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNGrotFieldModel.h"


@implementation SNGrotFieldModel

#pragma mark Constructor

+ (instancetype)randomModel
{
    return [[self.class alloc] initWithRandomValues];
}

- (instancetype)initWithRandomValues
{
    self = [super init];
    
    if (self)
    {
        [self randomizeValues];
        self.isAvailable = YES;
    }
    
    return self;
}

- (void)randomizeValues
{
    NSArray *colorTypeDistribution = @[ kColorGray, kColorGray, kColorGray, kColorGray,
                                        kColorBlue, kColorBlue, kColorBlue,
                                        kColorGreen, kColorGreen,
                                        kColorRed ];
    
    _colorType = randomElement(colorTypeDistribution);
    
    NSArray *directionDistribution = @[ @( SNFieldDirectionUp ), @( SNFieldDirectionLeft ), @( SNFieldDirectionDown ), @( SNFieldDirectionRight ) ];
    
    _direction = [randomElement(directionDistribution) integerValue];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Color: %@    Direction: %i    Available: %@", self.colorType, self.direction, self.isAvailable ? @"YES" : @"NO"];
}

#pragma mark - Methods

- (NSInteger)value
{
    return [self.class.points[_colorType] integerValue];
}

- (UIColor *)color
{
    return self.class.colors[_colorType];
}

- (float)angle
{
    return deg2rad(_direction);
}

#pragma mark - Default config

+ (NSDictionary *)colors
{
    return @{ kColorGray  : colorFromHex(0xffffff),
              kColorBlue  : colorFromHex(0xffec00),
              kColorGreen : colorFromHex(0xe50000),
              kColorRed   : colorFromHex(0x00968f) };
}

+ (NSDictionary *)points
{
    return @{ kColorGray  : @(1),
              kColorBlue  : @(2),
              kColorGreen : @(3),
              kColorRed   : @(4) };
}

@end
