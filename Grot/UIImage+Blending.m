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
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [image drawInRect:CGRectMake((self.size.width - image.size.width) / 2.0, (self.size.height - image.size.height) / 2.0, image.size.width, image.size.height)];
    UIImage* outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

@end
