//
//  UIPlaygroundGridView.h
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSGameState.h"
#import "UIArrowView.h"

@import SpriteKit;

@class UIPlaygroundGridView;

@protocol UIPlaygroundGridViewDataSource <NSObject>

@required
- (NSGameGrid*)gameGridForPlaygroundGridView;

@end

@protocol UIPlaygroundGridViewDelegate <NSObject>

@optional
- (void)playgroundGridView:(UIPlaygroundGridView*)playgroundGridView didSelectArrowView:(UIArrowView*)arrowView;
- (void)playgroundGridView:(UIPlaygroundGridView*)playgroundGridView didChangeFocus:(BOOL)focus ofArrowView:(UIArrowView*)arrowView;
- (void)playgroundGridView:(UIPlaygroundGridView*)playgroundGridView willReloadGridAnimated:(BOOL)animated;

@end

IB_DESIGNABLE
@interface UIPlaygroundGridView : SKView<UIArrowViewDelegate>

@property (nonatomic, strong, readonly) SKScene* scene;
@property (nonatomic) IBInspectable CGSize itemSize;
@property (nonatomic) IBInspectable CGSize itemSpacing;
@property (nonatomic, weak) IBOutlet id<UIPlaygroundGridViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<UIPlaygroundGridViewDelegate> delegate;

- (void)dismissGridWithCompletionHandler:(void (^)())completionBlock;
- (void)reloadGridAnimated:(BOOL)animated;
- (void)reloadMissingFieldsAnimated:(BOOL)animated;
- (void)prepareArrowViewsForReaction:(NSFieldReaction*)reaction;
- (NSArray*)arrowFieldsWithoutArrowView;
- (CGPoint)locationForArrowField:(NSArrowField*)arrowField;
- (CGPoint)locationForNodePosition:(CGPoint)nodePosition inGridOfSize:(CGSize)gridSize;
- (UIArrowView*)arrowViewForArrowField:(NSArrowField*)arrowField;
- (NSArray*)arrowViewsForArrowFields:(NSArray*)arrowFields;

@end
