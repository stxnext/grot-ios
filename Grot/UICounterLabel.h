//
//  UICounterLabel.h
//  Grot
//
//  Created by Dawid Żakowski on 04/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

@import UIKit;
#import "SNCounterLabelLayout.h"
#import "SNCounterLabelState.h"

@interface UICounterLabel : UILabel
{
    UIImage* _wheelImage;
    CGImageRef _gradientMask;
    dispatch_block_t _animationCompletionBlock;
}

@property (nonatomic, strong) SNCounterLabelLayout* layout;
@property (nonatomic, strong) SNCounterLabelState* state;
@property (nonatomic, strong) IBOutletCollection(UICounterLabel) NSArray* children;
@property (nonatomic) NSInteger maxValue;
@property (nonatomic) NSInteger maxDrawableValue;
@property (nonatomic) BOOL alignCenter;

- (void)setValue:(NSInteger)value animationSpeed:(CGFloat)speed completionHandler:(dispatch_block_t)completionBlock;

@end
