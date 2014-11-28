//
//  UIPlaygroundGridViewController.m
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIPlaygroundGridViewController.h"
#import "UIPlaygroundGridView.h"
#import "UIPlaygroundGridView+Animations.h"
#import "UIArrowView.h"

@implementation UIPlaygroundGridViewController

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _cancellationGuard = [NSObject new];
        _isAnimatingReaction = NO;
        _previousOrientation = UIDeviceOrientationUnknown;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Rotations observer
    if (INTERFACE_IS_PHONE && iOS8_PLUS)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.gridView addObserver:self forKeyPath:@"layer.bounds" options:0 context:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.gridView removeObserver:self forKeyPath:@"layer.bounds"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.gridView && [@"layer.bounds" isEqualToString:keyPath])
    {
        [self updateGridPropertiesAnimated:YES];
    }
}

- (void)restartGameWithGridSize:(CGSize)size initialMoves:(NSUInteger)moves
{
    [self.gridView dismissGridWithCompletionHandler:^{
        [self resetStateWithGridSize:size initialMoves:moves];
        [self updateGridPropertiesAnimated:YES];
    }];
}

- (void)resetStateWithGridSize:(CGSize)size initialMoves:(NSUInteger)moves
{
    SNGameResults* oldResults = nil;
    SNGameResults* newResults = nil;
    
    @synchronized (_cancellationGuard)
    {
        oldResults = self.gameState.results.copy;
        
        // Reset models
        SNGameState* state = SNGameState.new;
        state.grid = [SNGameGrid.alloc initWithSize:size];
        state.results = SNGameResults.zeroResults;
        state.results.moves = moves;
        [state.grid fillWithRandomItems];
        self.gameState = state;
        _isCancelled = _isAnimatingReaction;
        _isAnimatingReaction = NO;
        
        newResults = state.results.copy;
    }
    
    if ([self.delegate respondsToSelector:@selector(playgroundController:didChangeFromResults:toResults:)])
    {
        [self.delegate playgroundController:self didChangeFromResults:oldResults toResults:newResults];
    }
}

- (SNGameGrid*)gameGridForPlaygroundGridView
{
    return self.gameState.grid;
}

- (void)updateGridPropertiesAnimated:(BOOL)animated
{
    CGFloat screenWidth = self.gridView.frame.size.width;
    CGFloat screenHeight = self.gridView.frame.size.height;
    CGFloat screenShorterEdge = MIN(screenWidth, screenHeight);
    CGFloat margin = 0.060 * screenShorterEdge;
    CGFloat spacing = 0.020 * screenShorterEdge;
    CGFloat itemSizeH = (screenWidth - (margin * 2.0) - (spacing * (self.gameState.grid.size.width - 1))) / self.gameState.grid.size.width;
    CGFloat itemSizeV = (screenHeight - (margin * 2.0) - (spacing * (self.gameState.grid.size.height - 1))) / self.gameState.grid.size.height;
    CGFloat itemSize = MIN(itemSizeH, itemSizeV);
    
    self.gridView.itemSize = (CGSize){ itemSize, itemSize };
    self.gridView.itemSpacing = (CGSize){ spacing, spacing };
    
    [self reloadGridViewAnimated:animated];
}

- (void)reloadGridViewAnimated:(BOOL)animated
{
    if (self.gameState)
    {
        [self.gridView reloadGridAnimated:animated];
    }
}

- (void)finalizeScheduledReaction
{
    if (!self.gameState.scheduledReaction)
        return;
    
    SNGameResults* oldResults = self.gameState.results.copy;
    self.gameState = self.gameState.scheduledReaction.targetState.resolvedState;
    SNGameResults* newResults = self.gameState.results.copy;
    
    if ([self.delegate respondsToSelector:@selector(playgroundController:didChangeFromResults:toResults:)])
    {
        [self.delegate playgroundController:self didChangeFromResults:oldResults toResults:newResults];
    }
}

#pragma mark - Rotations

- (BOOL)shouldAutorotate
{
    return INTERFACE_IS_PAD;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (INTERFACE_IS_PAD)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (void)interfaceOrientationChanged:(NSNotification*)notification
{
    UIDevice* device = [UIDevice currentDevice];
    UIDeviceOrientation orientation = device.orientation;
    
    if (orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationFaceUp)
        return;
    
    CGFloat angle = 0.0;
    
    switch (orientation)
    {
        case UIDeviceOrientationPortrait: angle = 0.0; break;
        case UIDeviceOrientationPortraitUpsideDown: return;
        case UIDeviceOrientationLandscapeRight: angle = -M_PI_2; break;
        case UIDeviceOrientationLandscapeLeft: angle = M_PI_2; break;
    }
    
    NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.view.transform = CGAffineTransformMakeRotation(angle);
                     }];
}

#pragma mark - UIPlaygroundGridViewDelegate

- (void)playgroundGridView:(UIPlaygroundGridView*)playgroundGridView willReloadGridAnimated:(BOOL)animated;
{
    [self finalizeScheduledReaction];
    
    _isAnimatingReaction = NO;
}

- (void)playgroundGridView:(UIPlaygroundGridView*)playgroundGridView didChangeFocus:(BOOL)focus ofArrowView:(UIArrowView*)arrowView
{
    if (!focus)
        [self.gridView animateHighlightOfArrowView:arrowView toState:focus];
    
    if (_isAnimatingReaction)
        return;
    
    if (focus)
        [self.gridView animateHighlightOfArrowView:arrowView toState:focus];
}

- (void)playgroundGridView:(UIPlaygroundGridView*)playgroundGridView didSelectArrowView:(UIArrowView*)arrowView
{
    @synchronized (_cancellationGuard)
    {
        if (_isCancelled)
        {
            _isCancelled = NO;
            return;
        }
        
        @synchronized (self)
        {
            if (_isAnimatingReaction)
                return;
            
            _isAnimatingReaction = YES;
        }
        
        [self.gameState scheduleReactionAtField:arrowView.model];
        [self.gridView prepareArrowViewsForReaction:self.gameState.scheduledReaction];
        
        [self.gridView animateReaction:self.gameState.scheduledReaction
                 withCompletionHandler:^{
            @synchronized (_cancellationGuard)
            {
                if (_isCancelled)
                {
                    _isCancelled = NO;
                    return;
                }
                
                [self.gridView animatePushDownIntoGrid:self.gameState.scheduledReaction.targetState.fallenState.grid
                                 withCompletionHandler:^{
                    @synchronized (_cancellationGuard)
                    {
                        if (_isCancelled)
                        {
                            _isCancelled = NO;
                            return;
                        }
                        
                        [self finalizeScheduledReaction];
                        [self.gridView reloadMissingFieldsAnimated:YES];
                        
                        _isAnimatingReaction = NO;
                    }
                }];
            }
        }];
    }
}

@end
