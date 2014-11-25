//
//  UIFloatingController.h
//  Grot
//
//  Created by Dawid Żakowski on 20/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIMenuButton.h"

@interface UIFloatingController : UIViewController<UILabelExtLayoutDelegate, UIMenuButtonDelegate, UIMenuButtonDataSource>

@property (nonatomic) BOOL shouldAnimate;
@property (nonatomic, strong) IBOutletCollection(UIView) NSArray* fadedViews;
@property (nonatomic, strong) NSArray* menuButtons;
@property (nonatomic, strong) void (^menuButtonSelectionBlock)(UIFloatingButtonTag);

- (void)dismissWithCompletionHandler:(dispatch_block_t)completionBlock;

@end