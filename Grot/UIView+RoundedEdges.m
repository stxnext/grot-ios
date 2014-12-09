//
//  UIView+RoundedEdges.m
//  Grot
//
//  Created by Dawid Żakowski on 18.11.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIView+RoundedEdges.h"

@implementation UIView (RoundedEdges)

- (void)applyRoundedEdges
{
    self.layer.cornerRadius = (self.frame.size.width + self.frame.size.height) / 4.0;
}

@end
