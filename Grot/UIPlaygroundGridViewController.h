//
//  UIPlaygroundGridViewController.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaygroundGridView.h"

@protocol UIPlaygroundGridViewControllerDelegate;

@interface UIPlaygroundGridViewController : UIViewController<UIPlaygroundGridViewDataSource>
{
    UIDeviceOrientation _previousOrientation;
    BOOL _isAnimatingReaction;
    BOOL _isCancelled;
    NSObject* _cancellationGuard;
}

@property (nonatomic, strong) SNGameState* gameState;
@property (nonatomic, strong) IBOutlet UIPlaygroundGridView* gridView;
@property (nonatomic, weak) id<UIPlaygroundGridViewControllerDelegate> delegate;

- (void)restartGameWithGridSize:(CGSize)size initialMoves:(NSUInteger)moves;

@end

@protocol UIPlaygroundGridViewControllerDelegate <NSObject>

- (void)playgroundController:(UIPlaygroundGridViewController*)controller didChangeFromResults:(SNGameResults*)fromResults toResults:(SNGameResults*)toResults;

@end