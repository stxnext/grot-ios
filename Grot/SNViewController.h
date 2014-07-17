//
//  SNViewController.h
//  Grot
//
//  Created by Dawid Żakowski on 16/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SNFieldDirection) {
    SNFieldDirectionUp     = 0,
    SNFieldDirectionLeft   = 90,
    SNFieldDirectionDown   = 180,
    SNFieldDirectionRight  = 270,
    SNFieldDirectionsCount = 4
};

@interface SNMutableGrid : NSObject

@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) NSMutableDictionary* collection;
@property (nonatomic, strong, readonly) NSArray* indexPaths;

+ (instancetype)gridWithSize:(CGSize)size;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

@end

typedef NSString* SNFieldColor;

const static SNFieldColor kColorGray  = @"gray";
const static SNFieldColor kColorBlue  = @"blue";
const static SNFieldColor kColorGreen = @"green";
const static SNFieldColor kColorRed   = @"red";

@interface SNGrotFieldModel : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic, readonly) SNFieldColor colorType;
@property (nonatomic, readonly) SNFieldDirection direction;

+ (instancetype)randomModel;

- (NSInteger)value;
- (UIColor*)color;
- (float)angle;

@end

@interface SNGrotFieldView : UICollectionViewCell

@property (nonatomic, strong) SNGrotFieldModel* model;

@end

@interface SNGrotBoard : UICollectionViewController
{
    BOOL _isAnimatingTurn;
}

@property (nonatomic, strong, readonly) SNMutableGrid* fieldsGrid;

@end
