//
//  UILabelExt.m
//  Grot
//
//  Created by Dawid Żakowski on 12/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UILabelExt.h"

@implementation UILabelExt

- (void)updateConstraints
{
    [super updateConstraints];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.layoutDelegate respondsToSelector:@selector(labelDidUpdateConstraints:)])
        {
            [self.layoutDelegate labelDidUpdateConstraints:self];
        }
    });
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.layoutDelegate respondsToSelector:@selector(labelDidUpdateLayout:)])
        {
            [self.layoutDelegate labelDidUpdateLayout:self];
        }
    });
}

@end
