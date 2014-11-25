//
//  UIPlaygroundGridView+Animations.h
//  Grot
//
//  Created by Dawid Żakowski on 16/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIPlaygroundGridView.h"

@interface UIPlaygroundGridView (Animations)

- (void)animateFadeInForArrowViews:(NSArray*)arrowViews completionHandler:(void (^)())completionBlock;
- (void)animateFadeOutForArrowViews:(NSArray*)arrowViews completionHandler:(void (^)())completionBlock;
- (void)animateReaction:(SNFieldReaction*)reaction withCompletionHandler:(void (^)())completionBlock;
- (void)animatePushDownIntoGrid:(SNGameGrid*)targetGrid withCompletionHandler:(void (^)())completionBlock;
- (void)animateHighlightOfArrowView:(UIArrowView*)arrowView toState:(BOOL)highlighted;

@end
