//
//  UIColor+Blending.h
//  Grot
//
//  Created by Dawid Żakowski on 04/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Blending)

- (UIColor*)blendWithColor:(UIColor*)color percent:(CGFloat)percent;

@end
