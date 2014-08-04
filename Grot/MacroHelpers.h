//
//  MacroHelpers.h
//  Grot
//
//  Created by Dawid Żakowski on 30/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#define SCREEN_IS_RETINA                   ([UIScreen mainScreen].scale >= 2.0)
#define ORIENTATION_IS_PORTRAIT            (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))

#define INTERFACE_IS_PAD                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define INTERFACE_IS_PHONE_SMALL_SCREEN    (INTERFACE_IS_PHONE && [[UIScreen mainScreen] bounds].size.height != 568)
#define INTERFACE_IS_PHONE_5               (INTERFACE_IS_PHONE && [[UIScreen mainScreen] bounds].size.height >= 568)

#define DEVICE_IOS_VERSION                 ([[[UIDevice currentDevice] systemVersion] floatValue])
#define iOS7_PLUS                          (DEVICE_IOS_VERSION >= 7.0)
#define iOS6_PLUS                          (DEVICE_IOS_VERSION >= 6.0)

#define STATUS_BAR_HEIGHT                  ((UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) ? \
[UIApplication sharedApplication].statusBarFrame.size.height : [UIApplication sharedApplication].statusBarFrame.size.width)

#if TARGET_IPHONE_SIMULATOR
#define TARGET_IS_SIMULATOR YES
#define TARGET_IS_DEVICE NO
#else
#define TARGET_IS_SIMULATOR NO
#define TARGET_IS_DEVICE YES
#endif

#define colorFromHex(hex) ([UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0 \
green:((hex >> 8)  & 0xFF) / 255.0 \
blue:((hex >> 0)  & 0xFF) / 255.0 \
alpha:1.0])