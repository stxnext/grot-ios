//
//  UIColor+Blending.m
//  Grot
//
//  Created by Dawid Żakowski on 04/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIColor+Blending.h"

@implementation UIColor (Blending)

- (UIColor*)blendWithColor:(UIColor*)color percent:(CGFloat)percent
{
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [self getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [color getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    return [UIColor colorWithRed:r1 + (r2 - r1) * percent
                           green:g1 + (g2 - g1) * percent
                            blue:b1 + (b2 - b1) * percent
                           alpha:a1 + (a2 - a1) * percent];
}

@end
