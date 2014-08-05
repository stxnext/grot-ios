//
//  UIWindow+Splash.m
//  Grot
//
//  Created by Dawid Żakowski on 30/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIWindow+Splash.h"
#import <GPUImage/GPUImage.h>

@implementation SplashWindow
@end

@implementation UIWindow (Splash)

+ (SplashWindow*)splashWindow
{
    // Calculate splash image name
    BOOL iOS7 = iOS7_PLUS;
    BOOL iPad = INTERFACE_IS_PAD;
    BOOL iPhone5 = INTERFACE_IS_PHONE_5;
    BOOL portrait = ORIENTATION_IS_PORTRAIT;
    BOOL retina = SCREEN_IS_RETINA;
    
    NSString* imagePath
    =(iOS7 & iPhone5 & retina)?            @"LaunchImage-700-568h@2x.png"
    :(!iOS7 & iPhone5 & retina)?           @"LaunchImage-568h@2x.png"
    :(iOS7 & !iPad & !retina)?             @"LaunchImage.png" // exception
    :(iOS7 & !iPad & retina)?              @"LaunchImage-700@2x.png"
    :(!iOS7 & !iPad & !retina)?            @"LaunchImage.png"
    :(!iOS7 & !iPad & retina)?             @"LaunchImage@2x.png"
    :(iOS7 & iPad & !portrait & retina)?   @"LaunchImage-700-Landscape@2x~ipad.png"
    :(iOS7 & iPad & !portrait & !retina)?  @"LaunchImage-700-Landscape~ipad.png"
    :(iOS7 & iPad & portrait & retina)?    @"LaunchImage-700-Portrait@2x~ipad.png"
    :(iOS7 & iPad & portrait & !retina)?   @"LaunchImage-700-Portrait~ipad.png"
    :(!iOS7 & iPad & !portrait & retina)?  @"LaunchImage-Landscape@2x~ipad.png"
    :(!iOS7 & iPad & !portrait & !retina)? @"LaunchImage-Landscape~ipad.png"
    :(!iOS7 & iPad & portrait & retina)?   @"LaunchImage-Portrait@2x~ipad.png"
    :(!iOS7 & iPad & portrait & !retina)?  @"LaunchImage-Portrait~ipad.png"
    :                                      nil;
    
    
    if (iPad) {
        imagePath =@"LaunchImage-700-Portrait~ipad.png";
//                    LaunchImage-700-Portrait~ipad
    }
    // Load splash image with proper orientation and position
    UIImage* rawImage = [UIImage imageNamed:imagePath];
    UIImage* image = [UIImage imageWithCGImage:rawImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    UIImageView* splash = [[UIImageView alloc] initWithImage:image];
    
    GPUImageiOSBlurFilter* blurFilter = [GPUImageiOSBlurFilter new];
    blurFilter.blurRadiusInPixels = 12.0;
    blurFilter.saturation = 0.0;
    blurFilter.downsampling = 1.0;
    blurFilter.rangeReductionFactor = 0.0;
    UIImage* blurredImage = [blurFilter imageByFilteringImage:splash.image.copy];
    UIImageView* blurredSplash = [[UIImageView alloc] initWithImage:blurredImage];
    
    CGFloat angle;
    switch ([[UIApplication sharedApplication] statusBarOrientation])
    {
        case UIInterfaceOrientationPortrait:           angle = 0.0;         break;
        case UIInterfaceOrientationPortraitUpsideDown: angle = M_PI;        break;
        case UIInterfaceOrientationLandscapeLeft:      angle = -M_PI / 2.0; break;
        case UIInterfaceOrientationLandscapeRight:     angle = M_PI / 2.0;  break;
    }
    
    CGFloat verticalShift = (!iOS7 & iPad) ? STATUS_BAR_HEIGHT / 2.0 : 0.0;
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, angle);
    transform = CGAffineTransformTranslate(transform, 0, verticalShift);
    splash.transform = blurredSplash.transform = transform;
    splash.center = blurredSplash.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, [UIScreen mainScreen].bounds.size.height / 2.0);
    
    // Create new window with black bar and splash
    SplashWindow* splashWindow = [[SplashWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    splashWindow.mainImageView = splash;
    splashWindow.blurredImageView = blurredSplash;
    splashWindow.rootViewController = [UIViewController new];
    splashWindow.windowLevel = UIWindowLevelStatusBar;
    splashWindow.userInteractionEnabled = NO;
    [splashWindow addSubview:blurredSplash];
    [splashWindow addSubview:splash];
    
    return splashWindow;
}

@end
