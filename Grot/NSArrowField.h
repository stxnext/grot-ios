//
//  NSArrowField.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSArrowFieldDirection) {
    NSFieldDirectionUp,
    NSFieldDirectionLeft,
    NSFieldDirectionDown,
    NSFieldDirectionRight,
    NSFieldDirectionsCount
};

typedef NS_ENUM(NSInteger, NSArrowFieldType) {
    NSArrowFieldTypeLowest,
    NSArrowFieldTypeLow,
    NSArrowFieldTypeeHigh,
    NSArrowFieldTypeHighest,
    NSArrowFieldTypesCount
};

@interface NSArrowField : NSObject<NSCopying>

@property (nonatomic) BOOL isAvailable;
@property (nonatomic, readonly, getter = isUnknown) BOOL unknown;
@property (nonatomic, readonly) NSArrowFieldType type;
@property (nonatomic, readonly) NSArrowFieldDirection direction;

+ (UIColor*)arrowColor;
+ (NSDictionary*)backgroundColors;

- (NSInteger)value;
- (double)angle;
- (UIColor*)color;

+ (instancetype)modelWithType:(NSArrowFieldType)type direction:(NSArrowFieldDirection)direction;
+ (instancetype)unknownModel;
+ (instancetype)randomModel;

- (BOOL)resolveUnknown;

@end
