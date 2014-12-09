//
//  UICounterLabelState.h
//  Grot
//
//  Created by Dawid Żakowski on 04/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

@import UIKit;

@interface UICounterLabelState : NSObject

@property (nonatomic) NSInteger animationStartValue;
@property (nonatomic) NSInteger animationEndValue;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) NSTimeInterval animationStartTime;
@property (nonatomic, strong) CADisplayLink* displayLink;

@end
