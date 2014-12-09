//
//  UIFieldBadge.m
//  Grot
//
//  Created by Dawid Żakowski on 18.11.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFieldBadge.h"
#import "UIView+RoundedEdges.h"

@implementation UIFieldBadge

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    dispatch_async(dispatch_get_main_queue(), ^{ // delayed to match actual frame
        [self.iconView applyRoundedEdges];
    });
}

- (void)setType:(NSArrowFieldType)type
{
    _type = type;
    
    NSArrowField* field = [NSArrowField modelWithType:type direction:NSFieldDirectionUp];
    self.iconView.backgroundColor = field.color;
    self.nameLabel.text = [NSString stringWithFormat:@"× %d", (int)field.value];
}

@end
