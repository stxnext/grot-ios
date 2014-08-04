//
//  UIImage+Blending.m
//  Grot
//
//  Created by Dawid Żakowski on 04/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIImage+Blending.h"
#import <GPUImage/GPUImage.h>

@implementation UIImage (Blending)

- (UIImage*)addImage:(UIImage*)image
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [image drawInRect:CGRectMake((self.size.width - image.size.width) / 2.0, (self.size.height - image.size.height) / 2.0, image.size.width, image.size.height)];
    UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

- (UIImage*)rotateWithAngle:(CGFloat)rotation
{
    CGAffineTransform t = CGAffineTransformMakeRotation(rotation);
    CGRect sizeRect = (CGRect) {.size = self.size};
    CGRect destRect = CGRectApplyAffineTransform(sizeRect, t);
    CGSize destinationSize = destRect.size;
    
    UIGraphicsBeginImageContextWithOptions(destinationSize, NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, destinationSize.width / 2.0f, destinationSize.height / 2.0f);
    CGContextRotateCTM(context, rotation);
    [self drawInRect:CGRectMake(-self.size.width / 2.0f, -self.size.height / 2.0f, self.size.width, self.size.height)];
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
