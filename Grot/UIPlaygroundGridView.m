//
//  UIPlaygroundGridView.m
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIPlaygroundGridView.h"
#import "UIPlaygroundGridView+Animations.h"
#import "SKAction+Spring.h"

@implementation UIPlaygroundGridView

@synthesize scene = _scene;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _scene = SKScene.new;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self updateSceneProperties];
    
    [self addObserver:self forKeyPath:@"layer.bounds" options:0 context:nil];
    [self addObserver:self forKeyPath:@"backgroundColor" options:0 context:nil];
    
    if (iOS8_PLUS)
    {
        self.allowsTransparency = YES; // removes background color visible as line borders
    }
    
    [self presentScene:_scene];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self == object && [@"layer.bounds" isEqualToString:keyPath])
    {
        _scene.size = self.bounds.size;
        [self layoutArrowSubviews];
    }
    else if (self == object && [@"backgroundColor" isEqualToString:keyPath])
    {
        _scene.backgroundColor = self.backgroundColor;
        [self layoutArrowSubviews];
    }
}

- (void)updateSceneProperties
{
    _scene.size = self.bounds.size;
    _scene.backgroundColor = self.backgroundColor;
    
    [self layoutArrowSubviews];
}

- (NSArray*)arrowViewSubviews
{
    return [self.scene.children filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", UIArrowView.class]];
}

- (NSArray*)sortedArrowViews:(NSArray*)arrayViews
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    NSSortDescriptor* sortDesctiptor = [NSSortDescriptor sortDescriptorWithKey:@"model" ascending:YES comparator:[grid arrayFieldComparator]];
    NSArray* sortedViews = [arrayViews sortedArrayUsingDescriptors:@[ sortDesctiptor ]];
    
    return sortedViews;
}

- (UIArrowView*)addArrowSubviewAtPoint:(CGPoint)point withDecorator:(void (^)(UIArrowView* arrowView))decorator
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    SNArrowField* arrowField = [grid objectAtPoint:point];
    
    UIArrowView* arrowView = UIArrowView.new;
    arrowView.model = arrowField;
    arrowView.delegate = self;
    arrowView.userInteractionEnabled = YES;
    arrowView.size = self.itemSize;
    arrowView.zPosition = -1;
    
    if (decorator)
        decorator(arrowView);
    
    [self.scene addChild:arrowView];
    
    return arrowView;
}

- (void)addArrowSubviewsWithDecorator:(void (^)(UIArrowView* arrowView))decorator
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    
    for (NSUInteger y = 0; y < grid.size.height; y++)
    {
        for (NSUInteger x = 0; x < grid.size.width; x++)
        {
            CGPoint point = (CGPoint){ x, y };
            [self addArrowSubviewAtPoint:point withDecorator:decorator];
        }
    }
}

- (void)removeArrowSubviews
{
    NSArray* arrowViews = [self arrowViewSubviews];
    [self.scene removeChildrenInArray:arrowViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutArrowSubviews];
}

- (void)layoutArrowSubviews
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    NSArray* arrowViews = [self arrowViewSubviews];
    
    for (UIArrowView* arrowView in arrowViews)
    {
        CGPoint location = [self locationForNodePosition:[grid pointForObject:arrowView.model] inGridOfSize:grid.size];
        arrowView.position = location;
    }
}

- (void)dismissGridWithCompletionHandler:(void (^)())completionBlock
{
    NSArray* views = [self arrowViewSubviews];
    
    if (views.count > 0)
    {
        [self animateFadeOutForArrowViews:views completionHandler:^{
            [self removeArrowSubviews];
            
            if (completionBlock)
                completionBlock();
        }];
        
        return;
    }
    else
    {
        if (completionBlock)
            completionBlock();
    }
}

- (void)reloadGridAnimated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(playgroundGridView:willReloadGridAnimated:)])
    {
        [self.delegate playgroundGridView:self willReloadGridAnimated:animated];
    }
    
    // May also want to update bg color here
    [self removeArrowSubviews];
    
    [self addArrowSubviewsWithDecorator:^(UIArrowView *arrowView) {
        if (animated)
            arrowView.alpha = 0.0;
    }];
    
    [self layoutArrowSubviews];
    
    if (animated)
    {
        NSArray* sortedViews = [self sortedArrowViews:[self arrowViewSubviews]];
        [self animateFadeInForArrowViews:sortedViews completionHandler:nil];
    }
}

- (void)reloadMissingFieldsAnimated:(BOOL)animated
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    NSArray* orphanFields = [self arrowFieldsWithoutArrowView];
    NSMutableArray* arrowViews = [NSMutableArray array];
    
    for (SNArrowField* field in orphanFields)
    {
        CGPoint point = [grid pointForObject:field];
        
        UIArrowView* view = [self addArrowSubviewAtPoint:point withDecorator:^(UIArrowView *arrowView) {
            if (animated)
                arrowView.alpha = 0.0;
        }];
        
        [arrowViews addObject:view];
    }
    
    [self layoutArrowSubviews];
    
    if (animated)
    {
        NSArray* sortedViews = [self sortedArrowViews:arrowViews];
        [self animateFadeInForArrowViews:sortedViews completionHandler:nil];
    }
}

- (void)prepareArrowViewsForReaction:(SNFieldReaction*)reaction
{
    NSArray* transitions = reaction.fieldTransitions;
    
    for (int i = 0; i < transitions.count; i++)
    {
        SNFieldTransition* transition = transitions[i];
        SNArrowField* field = transition.arrowField;
        UIArrowView* view = [self arrowViewForArrowField:field];
        view.zPosition = transitions.count - i;
    }
}

- (NSArray*)arrowFieldsWithoutArrowView
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    NSMutableArray* fields = [NSMutableArray array];
    
    for (SNArrowField* field in grid.allObjects)
    {
        UIArrowView* view = [self arrowViewForArrowField:field];
        
        if (!view)
        {
            [fields addObject:field];
        }
    }
    
    return fields;
}

- (void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize;
    
    [self layoutArrowSubviews];
}

- (void)setItemSpacing:(CGSize)itemSpacing
{
    _itemSpacing = itemSpacing;
    
    [self layoutArrowSubviews];
}

- (CGPoint)locationForArrowField:(SNArrowField*)arrowField
{
    SNGameGrid* grid = self.dataSource.gameGridForPlaygroundGridView;
    CGPoint position = [grid pointForObject:arrowField];
    return [self locationForNodePosition:position inGridOfSize:grid.size];
}

- (CGPoint)locationForNodePosition:(CGPoint)nodePosition inGridOfSize:(CGSize)gridSize
{
    CGSize contentSize = CGSizeMake(gridSize.width * (self.itemSize.width + self.itemSpacing.width - 1),
                                    gridSize.height * (self.itemSize.height + self.itemSpacing.height - 1));
    CGPoint contentOffset = CGPointMake((self.frame.size.width - contentSize.width) * 0.5,
                                        (self.frame.size.height - contentSize.height) * 0.5);
    
    CGPoint itemPosition = CGPointMake(contentOffset.x + nodePosition.x * (self.itemSize.width + self.itemSpacing.width),
                                       contentOffset.y + (gridSize.height - 1 - nodePosition.y) * (self.itemSize.height + self.itemSpacing.height));
    
    // Adjust view position to point view's center
    itemPosition.x += self.itemSize.width * 0.5;
    itemPosition.y += self.itemSize.height * 0.5;
    
    return itemPosition;
}

- (UIArrowView*)arrowViewForArrowField:(SNArrowField*)arrowField
{
    NSArray* arrowViews = [self arrowViewSubviews];
    UIArrowView* arrowView = [arrowViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"model = %@", arrowField]].lastObject;
    return arrowView;
}

- (NSArray*)arrowViewsForArrowFields:(NSArray*)arrowFields
{
    NSMutableArray* views = [NSMutableArray array];
    
    for (SNArrowField* field in arrowFields)
    {
        UIArrowView* view = [self arrowViewForArrowField:field];
        [views addObject:view];
    }
    
    return views;
}

#if TARGET_INTERFACE_BUILDER
- (void)drawRect:(CGRect)rect
{
    const CGSize gridSize = (CGSize){ 4, 4 };
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIColor.blackColor setStroke];
    
    for (NSUInteger y = 0; y < gridSize.height; y++)
    {
        for (NSUInteger x = 0; x < gridSize.width; x++)
        {
            CGPoint position = (CGPoint){ x, y };
            CGPoint location = [self locationForNodePosition:position inGridOfSize:gridSize];
            CGRect frame = (CGRect){ location.x - self.itemSize.width * 0.5, location.y - self.itemSize.height * 0.5, self.itemSize.width, self.itemSize.height };
            CGContextStrokeEllipseInRect(context, frame);
        }
    }
}
#endif

#pragma mark - UIArrowViewDelegate

- (void)arrowViewTouchedDown:(UIArrowView *)arrowView
{
    if ([self.delegate respondsToSelector:@selector(playgroundGridView:didChangeFocus:ofArrowView:)])
    {
        [self.delegate playgroundGridView:self didChangeFocus:YES ofArrowView:arrowView];
    }
}

- (void)arrowViewTouchedUp:(UIArrowView *)arrowView inside:(BOOL)inside
{
    if ([self.delegate respondsToSelector:@selector(playgroundGridView:didChangeFocus:ofArrowView:)])
    {
        [self.delegate playgroundGridView:self didChangeFocus:NO ofArrowView:arrowView];
    }
    
    if (inside && [self.delegate respondsToSelector:@selector(playgroundGridView:didSelectArrowView:)])
    {
        [self.delegate playgroundGridView:self didSelectArrowView:arrowView];
    }
}

@end
