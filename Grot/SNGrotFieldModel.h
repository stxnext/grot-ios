//
//  SNGrotFieldModel.h
//  Grot
//
//  Created by Adam on 18.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

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

const static SNFieldColor kColor1 = @"1";
const static SNFieldColor kColor2 = @"2";
const static SNFieldColor kColor3 = @"3";
const static SNFieldColor kColor4 = @"4";


@interface SNGrotFieldModel : NSObject<NSCopying>

@property (nonatomic) CGPoint position;
@property (nonatomic) BOOL isAvailable;
@property (nonatomic, readonly) SNFieldColor colorType;
@property (nonatomic, readonly) SNFieldDirection direction;

+ (instancetype)modelWithColorType:(SNFieldColor)colorType direction:(SNFieldDirection)direction;
+ (instancetype)randomModel;

+ (NSDictionary *)colors;

- (NSInteger)value;
- (UIColor*)color;
- (float)angle;

@end
