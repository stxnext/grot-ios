//
//  UIFieldBadge.h
//  Grot
//
//  Created by Dawid Żakowski on 18.11.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSArrowField.h"

@interface UIFieldBadge : UIView

@property (nonatomic, strong) IBOutlet UIView* iconView;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;

@property (nonatomic) NSArrowFieldType type;

@end
