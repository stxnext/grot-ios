//
//  UIFloatingResultController.h
//  Grot
//
//  Created by Dawid Żakowski on 21/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFloatingController.h"
#import "UICounterLabel.h"
#import "UIResultDisk.h"

typedef NS_ENUM(UIFloatingButtonTag, UIFloatingResultButtonTag) {
    UIFloatingResultButtonRestartTag,
    UIFloatingResultButtonGameCenterTag,
};

@protocol UIFloatingResultControllerDataSource;

@interface UIFloatingResultController : UIFloatingController
{
    UIResultDisk* _resultDisk;
}

@property (nonatomic, weak) id<UIFloatingResultControllerDataSource> dataSource;

@end

@protocol UIFloatingResultControllerDataSource <NSObject>

@required
- (NSInteger)resultControllerCurrentScore;
- (NSInteger)resultControllerHighScore;

@end