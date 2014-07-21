//
//  SNGrotFieldModel.h
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

#define colorFromHex(hex) ([UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0 \
green:((hex >> 8)  & 0xFF) / 255.0 \
blue:((hex >> 0)  & 0xFF) / 255.0 \
alpha:1.0])

#define randomElement(array) array[arc4random_uniform(array.count)]

#define deg2rad(degrees) ((degrees) / 180.0 * M_PI)

typedef NS_ENUM(NSInteger, SNFieldDirection) {
    SNFieldDirectionUp     = 90,
    SNFieldDirectionLeft   = 180,
    SNFieldDirectionDown   = 270,
    SNFieldDirectionRight  = 0,
    SNFieldDirectionsCount = 4
};


typedef NSString* SNFieldColor;

const static SNFieldColor kColorGray  = @"gray";
const static SNFieldColor kColorBlue  = @"blue";
const static SNFieldColor kColorGreen = @"green";
const static SNFieldColor kColorRed   = @"red";


@interface SNGrotFieldModel : NSObject

//@property (nonatomic) CGPoint position;
@property (nonatomic) BOOL isAvailable;
@property (nonatomic, readonly) SNFieldColor colorType;
@property (nonatomic, readonly) SNFieldDirection direction;

+ (instancetype)randomModel;

- (NSInteger)value;
- (UIColor*)color;
- (float)angle;

@end