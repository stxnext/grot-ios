//
//  SNViewController.m
//  Grot
//
//  Created by Dawid Żakowski on 16/07/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SNViewController.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Macros

#define colorFromHex(hex) ([UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0 \
green:((hex >> 8)  & 0xFF) / 255.0 \
blue:((hex >> 0)  & 0xFF) / 255.0 \
alpha:1.0])

#define randomElement(array) array[arc4random_uniform(array.count)]

#define deg2rad(degrees) ((degrees) / 180.0 * M_PI)







#pragma mark -
@implementation SNMutableGrid

+ (instancetype)gridWithSize:(CGSize)size;
{
    return [[self.class alloc] initWithSize:size];
}

- (id)initWithSize:(CGSize)size
{
    self = [super init];
    
    if (self)
    {
        _size = size;
        _collection = NSMutableDictionary.dictionary;
        _indexPaths = [self.class possibleIndexPathsForSize:size];
    }
    
    return self;
}

- (NSUInteger)count
{
    return self.size.width * self.size.height;
}

- (id)objectAtIndex:(NSUInteger)index
{
    NSIndexPath* indexPath = _indexPaths[index];
    return self.collection[indexPath];
}

+ (NSArray*)possibleIndexPathsForSize:(CGSize)size
{
    NSMutableArray* array = NSMutableArray.array;
    
    for (NSUInteger y = 0; y < size.height; y++)
    {
        for (NSUInteger x = 0; x < size.width; x++)
        {
            NSIndexPath* path = [NSIndexPath indexPathForRow:x inSection:y];
            [array addObject:path];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

@end






#pragma mark -
@implementation SNGrotFieldModel

#pragma mark Constructor

+ (instancetype)randomModel
{
    return [[self.class alloc] initWithRandomValues];
}

- (instancetype)initWithRandomValues
{
    self = [super init];
    
    if (self)
    {
        [self randomizeValues];
        _available = YES;
    }
    
    return self;
}

- (void)randomizeValues
{
    NSArray* colorTypeDistribution = @[ kColorGray, kColorGray, kColorGray, kColorGray,
                                        kColorBlue, kColorBlue, kColorBlue,
                                        kColorGreen, kColorGreen,
                                        kColorRed ];
    
    _colorType = randomElement(colorTypeDistribution);
    
    NSArray* directionDistribution = @[ @( SNFieldDirectionUp ), @( SNFieldDirectionLeft ), @( SNFieldDirectionDown ), @( SNFieldDirectionRight ) ];
    
    _direction = [randomElement(directionDistribution) integerValue];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Position: %@    Color: %@    Direction: %i", NSStringFromCGPoint(self.position), self
            .colorType, self.direction];
}

#pragma mark - Methods

- (NSInteger)value
{
    return [self.class.points[_colorType] integerValue];
}

- (UIColor*)color
{
    return self.class.colors[_colorType];
}

- (float)angle
{
    return deg2rad(_direction);
}

#pragma mark - Default config

+ (NSDictionary*)colors
{
    return @{ kColorGray  : colorFromHex(0x95a5a6),
              kColorBlue  : colorFromHex(0x2980b9),
              kColorGreen : colorFromHex(0x27ae60),
              kColorRed   : colorFromHex(0xe74c3c) };
}

+ (NSDictionary*)points
{
    return @{ kColorGray  : @(1),
              kColorBlue  : @(2),
              kColorGreen : @(3),
              kColorRed   : @(4) };
}

@end






#pragma mark -
@implementation SNGrotFieldView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.layer.cornerRadius = MIN(self.frame.size.width, self.frame.size.height) / 2.0;
    self.layer.mask = [self.class arrowMaskForSize:self.frame.size];
}

- (void)setModel:(SNGrotFieldModel *)model
{
    _model = model;
    
    self.backgroundColor = _model.color;
    self.layer.affineTransform = CGAffineTransformMakeRotation(-_model.angle);
}

+ (UIBezierPath*)arrowPath
{
    static UIBezierPath* bezierPath;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bezierPath = UIBezierPath.bezierPath;
        
        [bezierPath moveToPoint: CGPointMake(0.145, 0.495)];
        [bezierPath addLineToPoint: CGPointMake(0.1453, 0.4758)];
        [bezierPath addCurveToPoint: CGPointMake(0.1904, 0.4321) controlPoint1: CGPointMake(0.1453, 0.4758) controlPoint2: CGPointMake(0.1388, 0.4321)];
        [bezierPath addLineToPoint: CGPointMake(0.6364, 0.4321)];
        [bezierPath addLineToPoint: CGPointMake(0.4353, 0.2362)];
        [bezierPath addCurveToPoint: CGPointMake(0.4353, 0.18) controlPoint1: CGPointMake(0.4353, 0.2362) controlPoint2: CGPointMake(0.3966, 0.2175)];
        [bezierPath addLineToPoint: CGPointMake(0.4675, 0.1489)];
        [bezierPath addCurveToPoint: CGPointMake(0.5255, 0.1489) controlPoint1: CGPointMake(0.4675, 0.1489) controlPoint2: CGPointMake(0.4933, 0.1177)];
        [bezierPath addLineToPoint: CGPointMake(0.8478, 0.4607)];
        [bezierPath addCurveToPoint: CGPointMake(0.8478, 0.5293) controlPoint1: CGPointMake(0.8478, 0.4607) controlPoint2: CGPointMake(0.8865, 0.4919)];
        [bezierPath addLineToPoint: CGPointMake(0.5255, 0.8411)];
        [bezierPath addCurveToPoint: CGPointMake(0.4675, 0.8411) controlPoint1: CGPointMake(0.5255, 0.8411) controlPoint2: CGPointMake(0.4998, 0.8723)];
        [bezierPath addLineToPoint: CGPointMake(0.4353, 0.81)];
        [bezierPath addCurveToPoint: CGPointMake(0.4353, 0.7538) controlPoint1: CGPointMake(0.4353, 0.81) controlPoint2: CGPointMake(0.3966, 0.7912)];
        [bezierPath addLineToPoint: CGPointMake(0.6364, 0.5579)];
        [bezierPath addLineToPoint: CGPointMake(0.1904, 0.5579)];
        [bezierPath addCurveToPoint: CGPointMake(0.1453, 0.5242) controlPoint1: CGPointMake(0.1904, 0.5579) controlPoint2: CGPointMake(0.1453, 0.5641)];
        
        [bezierPath closePath];
    });
    
    return bezierPath.copy;
}

+ (CAShapeLayer*)arrowMaskForSize:(CGSize)size
{
    const CGFloat scale = 0.6;
    
    CGPoint translation = CGPointMake((1.0 - scale) / 2.0, (1.0 - scale) / 2.0);
    
    UIBezierPath* arrowPath = self.class.arrowPath;
    [arrowPath applyTransform:CGAffineTransformMakeScale(scale, scale)];
    [arrowPath applyTransform:CGAffineTransformMakeTranslation(translation.x, translation.y)];
    [arrowPath applyTransform:CGAffineTransformMakeScale(size.width, size.height)];
    
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    UIBezierPath* maskPath = [UIBezierPath bezierPathWithRect:frame];
    [maskPath appendPath:arrowPath];
    
    CAShapeLayer* maskLayer = [CAShapeLayer new];
    maskLayer.path = maskPath.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    return maskLayer;
}

@end






#pragma mark -
@implementation SNGrotBoard

#define MARGIN 10
#define SPACE 5
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isAnimatingTurn = NO;
    size = 4;
    [self randomizeFieldModels];

//    
//    UIView *v = [[UIView alloc] initWithFrame:self.view.bounds];
//    v.backgroundColor = [UIColor redColor];
//    [self.view addSubview:v];
//    
//    CGSize screenSize = self.view.frame.size;
//    
//    CGFloat cellSize = (screenSize.width - 2*MARGIN - (size-1)*SPACE) / size;
//    CGFloat startY = screenSize.height - size * cellSize - MARGIN;
//    for (NSUInteger y = 0; y < size; y++)
//    {
//        for (NSUInteger x = 0; x < size; x++)
//        {
//            SNGrotFieldView* cell = [SNGrotFieldView new];
//            cell.model = [_fieldsGrid objectAtIndex:x + y * size];
//            CGRect cellFrame;
//
//            cellFrame.size.width = cellFrame.size.height = cellSize;
//            cell.frame = cellFrame;
//            cell.center = CGPointMake(MARGIN/2 + cellSize/2 + x*(cellSize + SPACE), startY + cellSize/2 + y*(cellSize + SPACE));
//
//            [v addSubview:cell];
//        }
//    }
//
}

- (void)randomizeFieldModels
{
    SNMutableGrid* grid = [SNMutableGrid gridWithSize:CGSizeMake(size, size)];
    
    for (NSIndexPath* indexPath in grid.indexPaths)
    {
        SNGrotFieldModel* model = [SNGrotFieldModel randomModel];
        model.position = CGPointMake(indexPath.row, indexPath.section);
        
        grid.collection[indexPath] = model;
    }
    
    _fieldsGrid = grid;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _fieldsGrid.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* reuseIdentifier = @"kGrotFieldCellReuseIdentifier";
    SNGrotFieldView* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [SNGrotFieldView new];
    }
    
    cell.model = [_fieldsGrid objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return !_isAnimatingTurn;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _isAnimatingTurn = YES;
    
    SNGrotFieldView *field = (SNGrotFieldView *)[collectionView cellForItemAtIndexPath:indexPath];

    if (field.model.available) {
        float delay = 0;
        
        for (SNGrotFieldView *field in animationsViews) {
                field.alpha = 0;
        }
        
        animationsViews = [NSMutableArray new];
        [self nextField:field level:1];
        delay = 0;
        
        for (SNGrotFieldView *field in animationsViews) {
            [UIView animateWithDuration:1 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
                field.alpha = 0.05;
            } completion:^(BOOL finished) {
            }];
            delay += 0.1;
        }
        
    }
    
    _isAnimatingTurn = NO;
}


- (SNGrotFieldView *)nextField:(SNGrotFieldView *)currentField level:(int)level
{
    if (currentField) {
        [animationsViews addObject:currentField];
    }
    
    currentField.model.available = NO;

    CGPoint newPosition = currentField.model.position;

    switch (currentField.model.direction) {
        case SNFieldDirectionUp:
            if (newPosition.y > level -1)
                newPosition.y -= level;
            else
                return nil;
            break;
            
        case SNFieldDirectionLeft:
            if (newPosition.x > level - 1)
                newPosition.x -= level;
            else
                return nil;
            break;
            
        case SNFieldDirectionDown:
            if (newPosition.y < size - level)
                newPosition.y += level;
            else
                return nil;
            break;
            
        case SNFieldDirectionRight:
            if (newPosition.x < size - level)
                newPosition.x += level;
            else
                return nil;
            break;
    }
    
    SNGrotFieldView *tempView = (SNGrotFieldView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:newPosition.x + newPosition.y * size inSection:0]];
    
    if (!tempView.model.available) {
        SNGrotFieldView *resultView = [self nextField:currentField level:++level];
        
        return resultView;
    }
    else
    {
        SNGrotFieldView *resultView = [self nextField:tempView level:1];

        return resultView;
    }
    
    return nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
