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

#pragma mark - Constructor

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    self.shouldAnimate = YES;
    
    return self;
}

#pragma mark - View cycle

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
        [button hide];
        
        [self setupMenuButton:button];
    }

    if ([self shouldShowControlsAutomatically])
    {
        [self showGraphicInterface];
        [self showButtons];
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

#pragma mark - Controls appearance

- (BOOL)shouldShowControlsAutomatically
{
    return YES;
}

- (void)showGraphicInterface
{
    [UIView animateWithDuration:0.4 * self.shouldAnimate
                     animations:^{
                         for (UIView* fadedView in self.fadedViews)
                             fadedView.alpha = 1.0;
                     } completion:nil];
}

- (void)showButtons
{
    for (UIMenuButton* button in self.menuButtons)
    {
        NSUInteger index = [self indexForMenuButton:button];
        [button showAnimated:self.shouldAnimate withDelay:(0.075 * index) withCompletionHandler:nil];
    }
}

- (void)updateButtonLayouts
{
    CGFloat minPointSize = CGFLOAT_MAX;
    
    for (UIMenuButton* button in self.menuButtons)
    {
        CGSize size = button.nameLabel.frame.size;
        CGFloat fontSize = [button.font maxFontSizeFittingBounds:size forText:button.text];
        minPointSize = MIN(minPointSize, fontSize);
    }
    
    for (UIMenuButton* button in self.menuButtons)
    {
        button.nameLabel.font = [button.nameLabel.font fontWithSize:minPointSize];
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

#pragma mark - Buttons delegates

- (void)labelDidUpdateLayout:(UILabelExt*)label
{
    [self updateButtonLayouts];
}

- (void)didTapMenuButton:(UIMenuButton*)button
{
    if (self.menuButtonSelectionBlock)
    {
        self.menuButtonSelectionBlock(button.tag);
    }
}

@end