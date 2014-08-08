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

+ (instancetype)modelWithColorType:(SNFieldColor)colorType direction:(SNFieldDirection)direction
{
    SNGrotFieldModel* model = self.class.new;
    [model setColorType:colorType direction:direction];
    model.isAvailable = YES;
    
    return model;
}

+ (instancetype)randomModel
{
    SNGrotFieldModel* model = self.class.new;
    [model randomizeValues];
    model.isAvailable = YES;
    
    return model;
}

- (id)copyWithZone:(NSZone *)zone
{
    SNGrotFieldModel* copy = [SNGrotFieldModel modelWithColorType:self.colorType.copy direction:self.direction];
    copy.position = self.position;
    copy.isAvailable = self.isAvailable;
    
    return copy;
}

- (void)setColorType:(SNFieldColor)colorType direction:(SNFieldDirection)direction
{
    _colorType = colorType;
    _direction = direction;
}

- (void)randomizeValues
{
    NSArray *colorTypeDistribution = @[ kColor1, kColor1, kColor1, kColor1,
                                        kColor2, kColor2, kColor2,
                                        kColor3, kColor3,
                                        kColor4 ];
    
    _colorType = randomElement(colorTypeDistribution);
    
    NSArray *directionDistribution = @[ @( SNFieldDirectionUp ), @( SNFieldDirectionLeft ), @( SNFieldDirectionDown ), @( SNFieldDirectionRight ) ];
    
    _direction = [randomElement(directionDistribution) integerValue];
}

- (NSString *)description
{
    NSString* arrowString
    = _direction == SNFieldDirectionUp    ? @"^"
    : _direction == SNFieldDirectionRight ? @">"
    : _direction == SNFieldDirectionDown  ? @"V"
    : _direction == SNFieldDirectionLeft  ? @"<"
    : @"?";
    
    return [NSString stringWithFormat:@"(%d, %d, %@)", (NSInteger)self.position.x, (NSInteger)self.position.y, arrowString];
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
    return @{ kColor1  : colorFromHex(0xffffff),
              kColor2  : colorFromHex(0xffec00),
              kColor3  : colorFromHex(0xe50f0f),
              kColor4  : colorFromHex(0x00968f) };
}

+ (NSDictionary *)points
{
    return @{ kColor1  : @(1),
              kColor2  : @(2),
              kColor3  : @(3),
              kColor4  : @(4) };
}

#pragma mark - Object equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class])
        return [super isEqual:object];
    
    SNGrotFieldModel* other = object;
    return self.hash == other.hash;
}

- (NSUInteger)hash
{
    return NSStringFromCGPoint(self.position).hash;
}

@end
