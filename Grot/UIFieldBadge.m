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
    
    [self.iconView applyRoundedEdges];
    
#warning HACK: iOS 7 compatibility
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.iconView applyRoundedEdges];
    });
}

- (void)setType:(SNArrowFieldType)type
{
    _type = type;
    
    SNArrowField* field = [SNArrowField modelWithType:type direction:SNFieldDirectionUp];
    self.iconView.backgroundColor = field.color;
    self.nameLabel.text = [NSString stringWithFormat:@"× %d", field.value];
}

@end
