//
//  UIBezierPath+Image.h
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBezierPath (Image)

- (UIImage*)fillImageWithColor:(UIColor*)color;
- (UIImage*)strokeImageWithColor:(UIColor*)color;

@end
