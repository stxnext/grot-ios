//
//  UIImage+Blending.h
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blending)

- (UIImage*)addImage:(UIImage*)image;
- (UIImage*)rotateWithAngle:(CGFloat)angle;

@end
