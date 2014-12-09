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

@property (nonatomic, strong) NSGameState* gameState;
@property (nonatomic, strong) IBOutlet UIPlaygroundGridView* gridView;
@property (nonatomic, weak) id<UIPlaygroundGridViewControllerDelegate> delegate;

- (void)restartGameWithGridSize:(CGSize)size initialScore:(NSUInteger)score initialMoves:(NSUInteger)moves;

@end

@protocol UIPlaygroundGridViewControllerDelegate <NSObject>

@optional
- (void)playgroundController:(UIPlaygroundGridViewController*)controller didDeductPenaltyFromState:(NSGameState*)fromState toState:(NSGameState*)toState;
- (void)playgroundController:(UIPlaygroundGridViewController*)controller willStartReaction:(NSFieldReaction*)reaction;
- (void)playgroundController:(UIPlaygroundGridViewController*)controller didChangeFromResults:(NSGameResults*)fromResults toResults:(NSGameResults*)toResults;

@end