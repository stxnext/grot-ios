//
//  UILabelExt.h
//  Grot
//
//  Created by Dawid Żakowski on 12/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UILabelExtLayoutDelegate;

@interface UILabelExt : UILabel

@property (nonatomic, weak) id<UILabelExtLayoutDelegate> layoutDelegate;

@end

@protocol UILabelExtLayoutDelegate <NSObject>

- (void)labelDidUpdateLayout:(UILabelExt*)label;

@end