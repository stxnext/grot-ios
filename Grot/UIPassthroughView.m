//
//  UIPassthroughView.m
//  Grot
//
//  Created by Dawid Żakowski on 04/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIPassthroughView.h"

@implementation UIPassthroughView

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    id hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self)
        return nil;
    else
        return hitView;
}

@end
