//
//  UICounterLabel.h
//  Grot
//
//  Created by Dawid Żakowski on 04/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

@import UIKit;
#import "UICounterLabelLayout.h"
#import "UICounterLabelState.h"

@interface UICounterLabel : UILabel
{
    UIImage* _wheelImage;
    CGImageRef _gradientMask;
    UIFont* _scaledFont;
    NSOperation* _animationCompletionOperation;
}

@property (nonatomic, strong) UICounterLabelLayout* layout;
@property (nonatomic, strong) UICounterLabelState* state;
@property (nonatomic, strong) IBOutletCollection(UICounterLabel) NSArray* children;
@property (nonatomic) NSInteger maxValue;
@property (nonatomic) NSInteger maxDrawableValue;
@property (nonatomic) BOOL alignCenter;
@property (nonatomic) CGPoint initialAlignShift;

- (void)setValue:(NSInteger)value animationSpeed:(CGFloat)speed completionHandler:(dispatch_block_t)completionBlock;
- (void)finishAnimation;

@end
