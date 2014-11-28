//
//  UIMenuButton.h
//  Grot
//
//  Created by Dawid Żakowski on 07/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabelExt.h"

typedef NSUInteger UIFloatingButtonTag;

@protocol UIMenuButtonDelegate;

@interface UIMenuButton : UIControl

@property (nonatomic, strong) IBInspectable UIImage* image;
@property (nonatomic, strong) IBInspectable NSString* text;
@property (nonatomic, strong) IBInspectable UIFont* font;
@property (nonatomic, strong) IBInspectable UIColor* color;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabelExt *nameLabel;

@property (nonatomic, weak) id<UIMenuButtonDelegate> delegate;

- (void)hide;
- (void)showAnimated:(BOOL)animated withDelay:(NSTimeInterval)delay withCompletionHandler:(dispatch_block_t)completionBlock;
- (void)dismissAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completionBlock;

@end

@protocol UIMenuButtonDelegate <NSObject>

@optional
- (void)didTapMenuButton:(UIMenuButton*)menuButton;

@end

@protocol UIMenuButtonDataSource <NSObject>

@optional
- (void)setupMenuButton:(UIMenuButton*)button;
- (NSUInteger)indexForMenuButton:(UIMenuButton*)button;

@end