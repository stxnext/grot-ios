//
//  UIFont+AutoSize.m
//  Grot
//
//  Created by Dawid Żakowski on 07/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFont+AutoSize.h"

#define OLD

@implementation UIFont (AutoSize)

- (NSInteger)maxFontSizeFittingWidth:(CGFloat)width forText:(NSString*)text withMin:(NSInteger)min max:(NSInteger)max
{
    if (max - min <= 1)
    {
        UIFont* font = [self fontWithSize:max];
        
#ifndef OLD
        NSAttributedString* attributed = [[NSAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName : font }];
        CGFloat textWidth = [attributed boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 context:0].size.width;
#else
        CGFloat textWidth = [text sizeWithFont:font].width;
#endif
        
        if (textWidth < width)
            return max;
        else
            return min;
    }
    
    NSInteger mid = (min + max) / 2;
    UIFont* font = [self fontWithSize:mid];
    
#ifndef OLD
    NSAttributedString* attributed = [[NSAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName : font }];
    CGFloat textWidth = [attributed boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 context:0].size.width;
#else
    CGFloat textWidth = [text sizeWithFont:font].width;
#endif
    
    if (textWidth < width)
        return [self maxFontSizeFittingWidth:width forText:text withMin:mid max:max];
    else
        return [self maxFontSizeFittingWidth:width forText:text withMin:min max:mid];
}

- (NSInteger)maxFontSizeFittingWidth:(CGFloat)width forText:(NSString*)text
{
    return [self maxFontSizeFittingWidth:width forText:text withMin:1 max:100];
}

- (NSInteger)maxFontSizeFittingBounds:(CGSize)bounds forText:(NSString*)text withMin:(NSInteger)min max:(NSInteger)max
{
    if (max - min <= 1)
    {
        UIFont* font = [self fontWithSize:max];
        
#ifndef OLD
        NSAttributedString* attributed = [[NSAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName : font }];
        CGFloat textHeight = [attributed boundingRectWithSize:CGSizeMake(bounds.width, CGFLOAT_MAX) options:0 context:0].size.height;
#else
        CGFloat textHeight = [text sizeWithFont:font constrainedToSize:CGSizeMake(bounds.width, CGFLOAT_MAX)].height;
#endif
        
        if (textHeight < bounds.height)
            return max;
        else
            return min;
    }
    
    NSInteger mid = (min + max) / 2;
    UIFont* font = [self fontWithSize:mid];
    
#ifndef OLD
    NSAttributedString* attributed = [[NSAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName : font }];
    CGFloat textHeight = [attributed boundingRectWithSize:CGSizeMake(bounds.width, CGFLOAT_MAX) options:0 context:0].size.height;
#else
    CGFloat textHeight = [text sizeWithFont:font constrainedToSize:CGSizeMake(bounds.width, CGFLOAT_MAX)].height;
#endif
    
    if (textHeight < bounds.height)
        return [self maxFontSizeFittingBounds:bounds forText:text withMin:mid max:max];
    else
        return [self maxFontSizeFittingBounds:bounds forText:text withMin:min max:mid];
}

- (NSInteger)maxFontSizeFittingBounds:(CGSize)bounds forText:(NSString*)text
{
    return [self maxFontSizeFittingBounds:bounds forText:text withMin:1 max:100];
}

@end