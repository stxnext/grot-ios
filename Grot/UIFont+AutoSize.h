//
//  UIFont+AutoSize.h
//  Grot
//
//  Created by Dawid Żakowski on 07/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (AutoSize)

- (NSInteger)maxFontSizeFittingWidth:(CGFloat)width forText:(NSString*)text;
- (NSInteger)maxFontSizeFittingBounds:(CGSize)bounds forText:(NSString*)text;

@end