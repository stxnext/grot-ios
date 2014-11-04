//
//  UIBezierPath+Image.m
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIBezierPath+Image.h"

@implementation UIBezierPath (Image)

- (UIImage*)fillImageWithColor:(UIColor*)color
{
    // adjust bounds to account for extra space needed for lineWidth
    CGFloat width = self.bounds.size.width + self.lineWidth * 2;
    CGFloat height = self.bounds.size.height + self.lineWidth * 2;
    CGRect bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
    
    // create a view to draw the path in
    UIView *view = [[UIView alloc] initWithFrame:bounds] ;
    
    // begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    // configure the view to render in the graphics context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // get reference to the graphics context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // reverse the y-axis to match the opengl coordinate space
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -view.bounds.size.height);
    
    // translate matrix so that path will be centered in bounds
    CGContextTranslateCTM(context, -(bounds.origin.x - self.lineWidth), -(bounds.origin.y - self.lineWidth));
    
    // set color
    [color set];
    
    [self fill];
    
    // get an image of the graphics context
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the context
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (UIImage*)strokeImageWithColor:(UIColor*)color
{
    // adjust bounds to account for extra space needed for lineWidth
    CGFloat width = self.bounds.size.width + self.lineWidth * 2;
    CGFloat height = self.bounds.size.height + self.lineWidth * 2;
    CGRect bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
    
    // create a view to draw the path in
    UIView *view = [[UIView alloc] initWithFrame:bounds] ;
    
    // begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    // configure the view to render in the graphics context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // get reference to the graphics context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // reverse the y-axis to match the opengl coordinate space
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -view.bounds.size.height);
    
    // translate matrix so that path will be centered in bounds
    CGContextTranslateCTM(context, -(bounds.origin.x - self.lineWidth), -(bounds.origin.y - self.lineWidth));
    
    // set color
    [color set];
    
    [self stroke];
    
    // get an image of the graphics context
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the context
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (UIImage*)fillImageWithGradientFromColor:(UIColor*)color1 toColor:(UIColor*)color2
{
    // adjust bounds to account for extra space needed for lineWidth
    CGFloat width = self.bounds.size.width + self.lineWidth * 2;
    CGFloat height = self.bounds.size.height + self.lineWidth * 2;
    CGRect bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height);
    
    // create a view to draw the path in
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    
    // begin graphics context for drawing
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    
    // configure the view to render in the graphics context
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // get reference to the graphics context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // reverse the y-axis to match the opengl coordinate space
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -view.bounds.size.height);
    
    // translate matrix so that path will be centered in bounds
    CGContextTranslateCTM(context, -(bounds.origin.x - self.lineWidth), -(bounds.origin.y - self.lineWidth));
    
    // colors
    CGFloat c1r, c1g, c1b, c1a, c2r, c2g, c2b, c2a;
    [color1 getRed:&c1r green:&c1g blue:&c1b alpha:&c1a];
    [color2 getRed:&c2r green:&c2g blue:&c2b alpha:&c2a];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { c1r, c1g, c1b, c1a, c2r, c2g, c2b, c2a };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, num_locations);
    CGPoint startPoint = CGPointMake(0.0, -CGRectGetHeight(self.bounds) / 2.0);
    CGPoint endPoint = CGPointMake(0.0, CGRectGetHeight(self.bounds) / 2.0);
    
    // draw
    CGContextAddPath(context, self.CGPath);
    CGContextEOClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    // get an image of the graphics context
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // end the context
    UIGraphicsEndImageContext();
    
    return viewImage;
}

@end
