//
//  UIFloatingMenuController.h
//  Grot
//
//  Created by Dawid Żakowski on 18.11.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFloatingController.h"

typedef NS_ENUM(UIFloatingButtonTag, UIFloatingMenuButtonTag) {
    UIFloatingMenuButtonResumeTag,
    UIFloatingMenuButtonRestartTag,
    UIFloatingMenuButtonGameCenterTag,
    UIFloatingMenuButtonInstructionsTag
};

@interface UIFloatingMenuController : UIFloatingController

@end