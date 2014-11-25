//
//  UIFloatingHelpController.h
//  Grot
//
//  Created by Dawid Żakowski on 18.11.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFloatingController.h"
#import "UIFieldBadge.h"

typedef NS_ENUM(UIFloatingButtonTag, UIFloatingHelpButtonTag) {
    UIFloatingHelpButtonReturnTag
};

@interface UIFloatingHelpController : UIFloatingController

@property (nonatomic, strong) NSArray* badges;

@end
