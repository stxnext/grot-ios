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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    const CGSize gridSize = (CGSize){ 4, 4 };
    const NSUInteger initialMoves = 5;
    
    [self resetStateWithGridSize:gridSize initialMoves:initialMoves];
    [self updateGridPropertiesAnimated:YES];
}

- (void)resetStateWithGridSize:(CGSize)size initialMoves:(NSUInteger)moves
{
    // Reset models
    SNGameState* state = SNGameState.new;
    state.grid = [SNGameGrid.alloc initWithSize:size];
    state.results = SNGameResults.zeroResults;
    state.results.moves = moves;
    [state.grid fillWithRandomItems];

    self.gameState = state;
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
    
    [self.gridView reloadGridAnimated:animated];
    
    self.gridView.backgroundColor = self.view.backgroundColor;
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

#pragma mark - UIPlaygroundGridViewDelegate

- (void)playgroundGridView:(UIPlaygroundGridView*)playgroundGridView didSelectArrowView:(UIArrowView*)arrowView
{
    SNGameResults* resultsDelta = SNGameResults.new;
    resultsDelta.moves = -1;
    [self.gameState.results add:resultsDelta];
    
    // TODO animate hud updates
    
    [self.gameState scheduleReactionAtField:arrowView.model];
    self.gridView.userInteractionEnabled = NO;
    [self.gridView prepareArrowViewsForReaction:self.gameState.scheduledReaction];
    
    [self.gridView animateReaction:self.gameState.scheduledReaction withCompletionHandler:^{
        self.gameState = self.gameState.scheduledReaction.targetState;
        
        SNGameGrid* fallenGrid = self.gameState.grid.copy;
        [fallenGrid pushDown];
        
        [self.gridView animatePushDownIntoGrid:fallenGrid withCompletionHandler:^{
            SNGameGrid* filledGrid = fallenGrid.copy;
            [filledGrid fillWithRandomItems];
            self.gameState.grid = filledGrid;

            [self.gridView reloadMissingFieldsAnimated:YES];
            self.gridView.userInteractionEnabled = YES;
        }];
    }];
}

@end
