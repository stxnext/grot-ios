//
//  UIFloatingController.m
//  Grot
//
//  Created by Dawid Żakowski on 20/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFloatingController.h"
#import "UIFont+AutoSize.h"

@implementation UIFloatingController

#pragma mark - View cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    self.shouldAnimate = YES;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (UIView* fadedView in self.fadedViews)
        fadedView.alpha = 0.0 + (!self.shouldAnimate);
    
    // Buttons setup
    for (UIMenuButton* button in self.menuButtons)
    {
        button.tag = button.superview.tag;
        button.nameLabel.layoutDelegate = self;
        button.delegate = self;
        
        [self setupMenuButton:button];
    }

    // Initial animations
    [UIView animateWithDuration:0.4 * self.shouldAnimate
                     animations:^{
                         for (UIView* fadedView in self.fadedViews)
                             fadedView.alpha = 1.0;
                     } completion:nil];
    
    // Buttons setup
    for (UIMenuButton* button in self.menuButtons)
    {
        NSUInteger index = [self indexForMenuButton:button];
        [button showAnimated:self.shouldAnimate withDelay:(0.075 * index) withCompletionHandler:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    UIViewController* controller = segue.destinationViewController;
    
    if ([controller.view isKindOfClass:[UIMenuButton class]])
    {
        // Buttons setup
        UIMenuButton* button = (UIMenuButton*)controller.view;
        
        NSArray* buttons = self.menuButtons ?: [NSArray array];
        buttons = [buttons arrayByAddingObject:button];
        self.menuButtons = buttons;
    }
}

#pragma mark - Dismissal

- (void)dismissWithCompletionHandler:(dispatch_block_t)completionBlock
{
    [UIView animateWithDuration:0.5 * self.shouldAnimate
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.view.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self dismissViewControllerAnimated:NO completion:nil];
                         
                         if (completionBlock)
                             completionBlock();
                     }];
    
    // Buttons setup
    for (UIMenuButton* button in self.menuButtons)
        [button dismissAnimated:self.shouldAnimate withCompletionHandler:nil];
}

#pragma mark - Buttons support

- (void)labelDidUpdateConstraints:(UILabelExt*)label
{
    [self updateFontForLabel:label];
}

- (void)labelDidUpdateLayout:(UILabelExt*)label
{
    [self updateFontForLabel:label];
}

- (void)updateFontForLabel:(UILabelExt*)label
{
    CGFloat pointSize = [self fontSizeForButtonSize:label.frame.size];
    label.font = [label.font fontWithSize:pointSize];
}

- (CGFloat)fontSizeForButtonSize:(CGSize)size
{
    CGFloat minPointSize = CGFLOAT_MAX;
    
    for (UIMenuButton* button in self.menuButtons)
    {
        CGFloat fontSize = [button.font maxFontSizeFittingBounds:size forText:button.text];
        minPointSize = MIN(minPointSize, fontSize);
    }
    
    return minPointSize;
}

- (void)didTapMenuButton:(UIMenuButton*)button
{
    if (self.menuButtonSelectionBlock)
    {
        self.menuButtonSelectionBlock(button.tag);
    }
}

@end