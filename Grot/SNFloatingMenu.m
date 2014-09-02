//
//  SNFloatingMenu.m
//  Grot
//
//  Created by Dawid Żakowski on 20/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNFloatingMenu.h"
#import "SNAppDelegate.h"
#import "GPUImage.h"

@implementation SNFloatingMenuController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuLabel.font = [UIFont fontWithName:@"Lato-Light" size:self.menuLabel.font.pointSize];
    
    if (INTERFACE_IS_PHONE)
    {
        self.menuLabel.font = [self.menuLabel.font fontWithSize:37];
        
        for (UILabel* label in self.labels)
            label.font = [label.font fontWithSize:22];
    }
    
    for (UIButton* button in self.buttons)
        button.alpha = 0.0;
    
    for (UILabel* label in self.labels)
        label.alpha = 0.0;
    
    self.dimView.alpha = self.menuLabel.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    for (UIButton* button in self.buttons)
    {
        button.alpha = 0.85;
        button.layer.transform = [self.class transformWithRotation:-1.0 scale:0.01];
    }
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self animateDim];
                     } completion:nil];
    
    [self animate];
}

- (void)animateDim
{
    self.dimView.alpha = self.menuLabel.alpha = 1.0;
}

+ (CATransform3D)transformWithRotation:(CGFloat)rotation scale:(CGFloat)scale
{
    CGAffineTransform affineTransform = CGAffineTransformMakeRotation(rotation);
    affineTransform = CGAffineTransformScale(affineTransform, scale, scale);
    CATransform3D transform3D = CATransform3DMakeAffineTransform(affineTransform);
    
    return transform3D;
}

- (void)animate
{
    __block NSInteger visibleIndex = 0;
    
    for (int i = 0; i < self.buttons.count; i++)
    {
        UIView* icon = self.buttons[i];
        UIView* label = self.labels[i];
        
        [UIView animateWithDuration:0.95
                              delay:0.2 + (0.075 * visibleIndex)
             usingSpringWithDamping:0.55
              initialSpringVelocity:2.0
                            options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             icon.layer.transform = [self.class transformWithRotation:0.0 scale:1.0];
                             icon.alpha = label.alpha = 1.0;
                         } completion:nil];
        
        visibleIndex++;
    }
}

- (void)dismissWithCompletionHandler:(dispatch_block_t)completionBlock
{
    for (UIView* view in self.buttons)
    {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1.2, 1.2));
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.3
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                                              animations:^{
                                                  view.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(0.0, 0.0));
                                                  view.alpha = 0.0;
                                              } completion:nil];
                         }];
    }
    
    for (UIView* view in self.labels)
    {
        [UIView animateWithDuration:0.45
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.alpha = 0.0;
                         } completion:nil];
    }
    
    [UIView animateWithDuration:0.5
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.view.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         [self.view.window setHidden:YES];
                         
                         SNAppDelegate* delegate = (SNAppDelegate*)UIApplication.sharedApplication.delegate;
                         [delegate.window makeKeyAndVisible];
                         
                         self.view.alpha = 1.0;
                         
                         if (completionBlock)
                             completionBlock();
                     }];
}

- (SNFloatingMenuOption)optionFromButton:(UIButton*)button
{
    if ([button isEqual:self.resumeButton])
        return SNFloatingMenuOptionResume;
    else if ([button isEqual:self.restartButton])
        return SNFloatingMenuOptionRestart;
    else if ([button isEqual:self.gameCenterButton])
        return SNFloatingMenuOptionGameCenter;
    else if ([button isEqual:self.instructionsButton])
        return SNFloatingMenuOptionInstructions;
    
    return -1;
}

#pragma mark - User actions

+ (NSString*)nibName
{
    return @"SNFloatingMenu";
}

+ (SNFloatingMenuController*)controllerForCurrentClass
{
    static NSCache* cache;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = NSCache.new;
    });
    
    NSString* nibName = self.nibName;
    SNFloatingMenuController* controller = [cache objectForKey:nibName];
    
    if (!controller)
    {
        controller = [self.class.alloc initWithNibName:nibName bundle:nil];
//        [cache setObject:controller forKey:nibName]; // TODO: enable caching, handle view reusability (animation state, view constraints)
    }
    
    return controller;
}

+ (SNFloatingMenuController*)showMenuWithDecorator:(void (^)(SNFloatingMenuController* menu))decoratorBlock
{
    static UIWindow* window = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = UIWindow.new;
        window.frame = [UIScreen mainScreen].bounds;
        window.windowLevel = UIWindowLevelNormal;
    });
    
    window.rootViewController = self.class.controllerForCurrentClass;
    [window makeKeyAndVisible];
    
    SNFloatingMenuController* controller = (SNFloatingMenuController*)window.rootViewController;
    
    if (decoratorBlock)
        decoratorBlock(controller);
    
    return controller;
}

- (IBAction)selectMenuItem:(UIButton*)sender
{
    if (self.menuSelectionBlock)
    {
        SNFloatingMenuOption option = [self optionFromButton:sender];
        self.menuSelectionBlock(option);
    }
}

@end