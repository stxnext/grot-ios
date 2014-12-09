//
//  UICounterLabelLayout.h
//  Grot
//
//  Created by Dawid Żakowski on 04/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, UICounterLabelArrowPart) {
    UICounterLabelArrowPartNone = 0,
    UICounterLabelArrowPartTail = 1 << 0,
    UICounterLabelArrowPartBody = 1 << 1,
    UICounterLabelArrowPartHead = 1 << 2,
};

static const UICounterLabelArrowPart UICounterLabelArrowPartAll = UICounterLabelArrowPartTail | UICounterLabelArrowPartBody | UICounterLabelArrowPartHead;

typedef struct {
    CGFloat horizontal;
    CGFloat vertical;
} UISpacing;

typedef struct {
    CGFloat offsetFactor;
    CGFloat lengthFactor;
} UIGradient;

@interface UICounterLabelLayout : NSObject

//@property (nonatomic) UICounterLabelArrowPart arrowDrawnParts;
//@property (nonatomic) CGPoint ringOffset;
//@property (nonatomic) CGPoint alignShift;
//@property (nonatomic) UISpacing spacing;
//@property (nonatomic) UIGradient gradient;

@property (nonatomic) UICounterLabelArrowPart arrowDrawnParts;
@property (nonatomic) CGSize wheelCellSpacing;
//@property (nonatomic) CGFloat wheelGradientOffset;
//@property (nonatomic) CGFloat wheelGradientSize;
@property (nonatomic) CGPoint ringOffset;
@property (nonatomic) CGPoint wheelShift;
@property (nonatomic) CGPoint alignShift;

@end
