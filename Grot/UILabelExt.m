//
//  UILabelExt.m
//  Grot
//
//  Created by Dawid Żakowski on 12/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UILabelExt.h"

@implementation UILabelExt

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.layoutDelegate respondsToSelector:@selector(labelDidUpdateLayout:)])
    {
        [self.layoutDelegate labelDidUpdateLayout:self];
    }
}

@end
