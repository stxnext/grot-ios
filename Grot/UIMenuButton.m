//
//  UIMenuButton.m
//  Grot
//
//  Created by Dawid Żakowski on 07/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIMenuButton.h"

@implementation UIMenuButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addTarget:self action:@selector(buttonDidTap:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Properties

- (void)setImageView:(UIImageView *)imageView
{
    _imageView = imageView;
}

- (void)setText:(NSString *)text
{
    self.nameLabel.text = text;
}

- (NSString*)text
{
    return self.nameLabel.text;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (UIImage*)image
{
    return self.imageView.image;
}

- (void)setFont:(UIFont *)font
{
    self.nameLabel.font = font;
}

- (UIFont*)font
{
    return self.nameLabel.font;
}

- (void)setColor:(UIColor *)color
{
    self.nameLabel.textColor = color;
}

- (UIColor*)color
{
    return self.nameLabel.textColor;
}

#pragma mark - Animations

- (void)hide
{
    self.alpha = 0.0;
}

- (void)showAnimated:(BOOL)animated withDelay:(NSTimeInterval)delay withCompletionHandler:(dispatch_block_t)completionBlock;
{
    self.alpha = 1.0;
    
    self.nameLabel.alpha = 0.0;
    self.imageView.alpha = 0.85;
    self.imageView.layer.transform = [self.class transformWithRotation:-1.0 scale:0.01];
    
    [UIView animateWithDuration:0.4 * animated
                     animations:^{
                         self.nameLabel.alpha = 1.0;
                     } completion:nil];
    
    [UIView animateWithDuration:0.95 * animated
                          delay:(0.2 + delay) * animated
         usingSpringWithDamping:0.55
          initialSpringVelocity:2.0
                        options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.imageView.layer.transform = [self.class transformWithRotation:0.0 scale:1.0];
                         self.imageView.alpha = self.nameLabel.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         if (completionBlock)
                             completionBlock();
                     }];
}

+ (CATransform3D)transformWithRotation:(CGFloat)rotation scale:(CGFloat)scale
{
    CGAffineTransform affineTransform = CGAffineTransformMakeRotation(rotation);
    affineTransform = CGAffineTransformScale(affineTransform, scale, scale);
    CATransform3D transform3D = CATransform3DMakeAffineTransform(affineTransform);
    
    return transform3D;
}

- (void)dismissAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completionBlock
{
    [UIView animateWithDuration:0.15 * animated
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.imageView.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(1.2, 1.2));
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 * animated
                                               delay:0.0
                                             options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              self.imageView.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeScale(0.01, 0.01));
                                              self.imageView.alpha = 0.0;
                                          } completion:nil];
                     }];
    
    [UIView animateWithDuration:0.3 * animated
                          delay:0.15 * animated
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.nameLabel.alpha = 0.0;
                     } completion:nil];
}

#pragma mark - User actions

- (void)buttonDidTap:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTapMenuButton:)])
    {
        [self.delegate didTapMenuButton:self];
    }
}

@end
