//
//  SNArrowField.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SNArrowFieldDirection) {
    SNFieldDirectionUp,
    SNFieldDirectionLeft,
    SNFieldDirectionDown,
    SNFieldDirectionRight,
    SNFieldDirectionsCount
};

typedef NS_ENUM(NSInteger, SNArrowFieldType) {
    SNArrowFieldTypeLowest,
    SNArrowFieldTypeLow,
    SNArrowFieldTypeeHigh,
    SNArrowFieldTypeHighest,
    SNArrowFieldTypesCount
};

@interface SNArrowField : NSObject<NSCopying>

@property (nonatomic) BOOL isAvailable;
@property (nonatomic, readonly, getter = isUnknown) BOOL unknown;
@property (nonatomic, readonly) SNArrowFieldType type;
@property (nonatomic, readonly) SNArrowFieldDirection direction;
@property (nonatomic, readonly) NSInteger value;
@property (nonatomic, readonly) UIColor* color;
@property (nonatomic, readonly) double angle;

+ (instancetype)modelWithType:(SNArrowFieldType)type direction:(SNArrowFieldDirection)direction;
+ (instancetype)unknownModel;
+ (instancetype)randomModel;

- (BOOL)resolveUnknown;

@end
