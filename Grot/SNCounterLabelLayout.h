//
//  SNCounterLabelLayout.h
//  Grot
//
//  Created by Dawid Żakowski on 04/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSInteger, SNCounterLabelArrowPart) {
    SNCounterLabelArrowPartNone = 0,
    SNCounterLabelArrowPartTail = 1 << 0,
    SNCounterLabelArrowPartBody = 1 << 1,
    SNCounterLabelArrowPartHead = 1 << 2,
};

static const SNCounterLabelArrowPart SNCounterLabelArrowPartAll = SNCounterLabelArrowPartTail | SNCounterLabelArrowPartBody | SNCounterLabelArrowPartHead;

typedef struct {
    CGFloat horizontal;
    CGFloat vertical;
} UISpacing;

typedef struct {
    CGFloat offsetFactor;
    CGFloat lengthFactor;
} UIGradient;

@interface SNCounterLabelLayout : NSObject

//@property (nonatomic) SNCounterLabelArrowPart arrowDrawnParts;
//@property (nonatomic) CGPoint ringOffset;
//@property (nonatomic) CGPoint alignShift;
//@property (nonatomic) UISpacing spacing;
//@property (nonatomic) UIGradient gradient;

@property (nonatomic) SNCounterLabelArrowPart arrowDrawnParts;
@property (nonatomic) CGSize wheelCellSpacing;
//@property (nonatomic) CGFloat wheelGradientOffset;
//@property (nonatomic) CGFloat wheelGradientSize;
@property (nonatomic) CGPoint ringOffset;
@property (nonatomic) CGPoint wheelShift;
@property (nonatomic) CGPoint alignShift;

@end
