//
//  SNCounterLabel.h
//  Grot
//
//  Created by Dawid Żakowski on 25/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SNCounterLabelArrowPart) {
    SNCounterLabelArrowPartNone = 0,
    SNCounterLabelArrowPartTail = 1 << 0,
    SNCounterLabelArrowPartBody = 1 << 1,
    SNCounterLabelArrowPartHead = 1 << 2,
};

static const SNCounterLabelArrowPart SNCounterLabelArrowPartAll = SNCounterLabelArrowPartTail | SNCounterLabelArrowPartBody | SNCounterLabelArrowPartHead;

@interface SNCounterLabelLayout : NSObject

@property (nonatomic) SNCounterLabelArrowPart arrowDrawnParts;
@property (nonatomic) CGSize wheelCellSpacing;
@property (nonatomic) CGFloat wheelGradientOffset;
@property (nonatomic) CGFloat wheelGradientSize;
@property (nonatomic) CGPoint ringOffset;

@end

@interface SNCounterState : NSObject

@property (nonatomic) NSInteger animationStartValue;
@property (nonatomic) NSInteger animationEndValue;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) NSTimeInterval animationStartTime;
@property (nonatomic, strong) CADisplayLink* displayLink;

@end

@interface SNCounterLabel : UILabel
{
    UIImage* _wheelImage;
    CGImageRef _gradientMask;
    dispatch_block_t _animationCompletionBlock;
}

@property (nonatomic, strong) SNCounterLabelLayout* layout;
@property (nonatomic, strong) SNCounterState* state;
@property (nonatomic, strong) IBOutletCollection(SNCounterLabel) NSArray* children;
@property (nonatomic) NSInteger maxValue;
@property (nonatomic) NSInteger maxDrawableValue;

- (void)setValue:(NSInteger)value animationSpeed:(CGFloat)speed completionHandler:(dispatch_block_t)completionBlock;

@end
