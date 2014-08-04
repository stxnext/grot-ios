//
//  UIWindow+Splash.h
//  Grot
//
//  Created by Dawid Żakowski on 30/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SplashWindow : UIWindow

@property (nonatomic, strong) UIImageView* mainImageView;
@property (nonatomic, strong) UIImageView* blurredImageView;

@end

@interface UIWindow (Splash)

+ (SplashWindow*)splashWindow;

@end