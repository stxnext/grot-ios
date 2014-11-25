//
//  UICounterLabel.m
//  Grot
//
//  Created by Dawid Żakowski on 04/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UICounterLabel.h"
#import "objc/runtime.h"
#import "RSTimingFunction.h"

#define CGContextFillRing(context, point, radius) CGContextFillEllipseInRect(context, CGRectMake(point.x - radius / 2.0, point.y - radius / 2.0, radius, radius))
#define CGContextAddLine(context, startPoint, endPoint) CGContextAddLines(context, (CGPoint[]){ startPoint, endPoint }, 2)
#define INTERFACE_IS_PHONE                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

@implementation UICounterLabel

const static UIGradient gradientFactor = (UIGradient){ 0.35, 0.50 };
const static CGSize glyphSizePaddingFactor = (CGSize){ 1.05, 0.85 };
const static CGSize maxLabelSize = (CGSize){ 999.9, 999.9 };
const static CGFloat shiftAnimationDuration = 0.3;
const static CGSize wheelCellSize = (CGSize){ 100.0, 100.0 };
const static NSInteger wheelAnimationEasingMagnitude = 3;

+ (UIImage*)imageWithSize:(CGSize)size drawingBlock:(void (^)(CGSize size))block
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (context) CGContextSaveGState(context);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    block(size);
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (context) CGContextRestoreGState(context);
    
    return image;
}

- (UILabel*)labelCopy
{
    UILabel* label = UILabel.new;
    label.textColor = self.textColor;
    label.font = self.font;
    
    return label;
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    _wheelImage = nil;
    [self updateCounterLayout];
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    _wheelImage = nil;
    [self setNeedsDisplay];
}

+ (CGSize)glyphSizeForFont:(UIFont*)font
{
    NSArray* numbers = @[ @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9" ];
    CGSize maxSize = (CGSize){ 0.0, 0.0 };
    
    for (NSInteger i = 0; i < numbers.count; i++)
    {
        NSString* numberString = numbers[i];
        UILabel* label = [UILabel.alloc init];
        label.font = font;
        label.frame = CGRectMake(0.0, 0.0, maxLabelSize.width, maxLabelSize.height);
        label.text = numberString;
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        maxSize.width = MAX(maxSize.width, label.frame.size.width);
        maxSize.height = MAX(maxSize.height, label.frame.size.height);
    }
    
    maxSize.width *= glyphSizePaddingFactor.width;
    maxSize.height *= glyphSizePaddingFactor.height;
    
    return maxSize;
}

- (CGImageRef)gradientMask
{
    if (!_gradientMask)
    {
        // TODO: gradient mask based on frame and glyph size
    }
    
    return _gradientMask;
}

- (UIImage*)wheelImage
{
    if (!_wheelImage)
    {
        NSArray* numbers = @[ @" ", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0" ];
        UIView* containerView = UIView.new;
        containerView.frame = CGRectMake(0.0, 0.0, self.layout.wheelCellSpacing.width, numbers.count * self.layout.wheelCellSpacing.height);
        containerView.backgroundColor = UIColor.clearColor;
        
        for (NSInteger i = 0; i < numbers.count; i++)
        {
            NSString* numberString = numbers[i];
            UILabel* label = self.labelCopy;
            label.backgroundColor = UIColor.clearColor;
            label.frame = CGRectMake(0.0, 0.0, wheelCellSize.width, wheelCellSize.height);
            label.text = numberString;
            [label sizeToFit];
            label.center = CGPointMake(self.layout.wheelCellSpacing.width * 0.5, self.layout.wheelCellSpacing.height * (i + 0.5));
            [containerView addSubview:label];
        }
        
        _wheelImage = [self.class imageWithSize:containerView.bounds.size drawingBlock:^(CGSize size){
            [containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
        }];
    }
    
    return _wheelImage;
}

+ (NSArray*)drawingPointsForCanvasOfSize:(CGSize)canvasSize
                            wheelSpacing:(CGSize)wheelSpacing
                              wheelCount:(NSInteger)wheelsCount
                               fromValue:(NSInteger)startValue
                                 toValue:(NSInteger)endValue
                              atProgress:(CGFloat)progress
{
    NSMutableArray* points = NSMutableArray.array;
    CGPoint origin = CGPointMake((canvasSize.width - wheelsCount * wheelSpacing.width) / 2.0, (canvasSize.height - wheelSpacing.height) / 2.0);
    BOOL isLeading = YES;
    
    for (int i = 0; i < wheelsCount; i++)
    {
        NSInteger invertedI = wheelsCount - i - 1;
        NSInteger divider = pow(10, invertedI);
        NSInteger startPart = startValue / divider;
        NSInteger endPart = endValue / divider;
        NSInteger partialDiff = endPart - startPart;
        CGFloat diffProgress = (CGFloat)partialDiff * progress;
        CGFloat progressValue = (CGFloat)startPart + diffProgress;
        NSInteger overhead = ((NSInteger)progressValue / 10) * 10;
        CGFloat unit = progressValue - (CGFloat)overhead;
        isLeading &= progressValue < 10.0;
        isLeading &= i < (wheelsCount - 1);
        BOOL threshold = (unit >= 0 && unit < 4 && !isLeading);
        NSInteger thresholdValue = threshold ? 10 : 0;
        CGFloat wheelIndex = unit + thresholdValue;
        CGFloat wheelOffset = wheelIndex * wheelSpacing.height;
        CGPoint point = CGPointMake(origin.x + wheelSpacing.width * i, origin.y - wheelOffset);
        NSValue* pointObject = [NSValue valueWithCGPoint:point];
        [points addObject:pointObject];
    }
    
    return points;
}

#pragma mark - Received actions

- (void)updateCenterAlignment
{
    if (!self.alignCenter)
        return;
    
    @synchronized (self)
    {
        NSInteger drawnWheelsCount = ((NSInteger)log10(MAX(1, self.maxDrawableValue))) + 1;
        NSInteger visibleWheelsCount = ((NSInteger)log10(MAX(1, self.state.animationEndValue))) + 1;
        NSInteger missingWheelsCount = MAX(0, drawnWheelsCount - visibleWheelsCount);
        CGPoint newShift = CGPointMake(self.layout.wheelCellSpacing.width * ((CGFloat)missingWheelsCount) * -0.5, 0.0);
        
        if (CGPointEqualToPoint(self.layout.alignShift, newShift))
            return;
        
        self.layout.alignShift = newShift;
    }
}

- (void)setValue:(NSInteger)value animationSpeed:(CGFloat)speed completionHandler:(dispatch_block_t)completionBlock
{
    [self.state.displayLink invalidate];
    self.state.displayLink = nil;
    
    CGFloat oldValue = self.state.animationEndValue;
    BOOL shouldAnimate = speed < NSIntegerMax && value != oldValue;
    
    _animationCompletionBlock = completionBlock;
    self.state.animationEndValue = value;
    self.state.animationStartTime = 0;
    
    CGPoint oldShift = self.layout.alignShift;
    [self updateCenterAlignment];
    
    if (shouldAnimate)
    {
        [self.window setNeedsDisplay];
        
        self.state.animationStartValue = oldValue;
        self.state.animationStartTime = 0;
        self.state.animationDuration = (ABS((CGFloat)(self.state.animationEndValue - self.state.animationStartValue)) * 0.002 + 2.0) / speed;
        self.state.animationInitialAlignShift = oldShift;
        self.state.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
        [self.state.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    else
    {
        self.state.animationStartValue = self.state.animationEndValue;
        self.state.animationInitialAlignShift = self.layout.alignShift;
        [self setNeedsDisplay];
    }
    
    [self updateCenterAlignment];
}

- (void)setAlignCenter:(BOOL)alignCenter
{
    _alignCenter = alignCenter;
    
    [self updateCenterAlignment];
    [self setNeedsDisplay];
}

- (void)updateCounterLayout
{
    self.layout.wheelCellSpacing = [self.class glyphSizeForFont:self.font];
    
    _gradientMask = nil;
    _wheelImage = nil;
}

#pragma mark - View methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.layout = SNCounterLabelLayout.new;
        self.layout.arrowDrawnParts = SNCounterLabelArrowPartNone;
        self.state = SNCounterLabelState.new;
        self.alignCenter = YES;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addObserver:self forKeyPath:@"layer.bounds" options:0 context:nil];
    
    [self updateCounterLayout];
    [self setValue:self.text.integerValue animationSpeed:NSIntegerMax completionHandler:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"layer.bounds"] && object == self)
    {
        [self updateCounterLayout];
    }
}

- (void)drawRect:(CGRect)rect
{
    CGFloat linkProgress = 1.0;
    CGFloat progress = 1.0;
    
    // Calculate progress depending on display link animation step
    if (self.state.displayLink)
    {
        if (self.state.animationStartTime == 0)
            self.state.animationStartTime = self.state.displayLink.timestamp;
        
        CFTimeInterval elaspedTime = self.state.displayLink.timestamp - self.state.animationStartTime;
        linkProgress = progress = MIN(1.0, elaspedTime / self.state.animationDuration);
        
        RSTimingFunction* easeFunction = [RSTimingFunction timingFunctionWithControlPoint1:CGPointMake(0.75, 0.0) controlPoint2:CGPointMake(0.4, 1.0)];
        easeFunction.duration = 0.000001;
        
        for (int i = 0; i < wheelAnimationEasingMagnitude; i++)
            progress = [easeFunction valueForX:progress];
        
        if (elaspedTime >= self.state.animationDuration)
        {
            [self.state.displayLink invalidate];
            self.state.displayLink = nil;
        }
    }
    
    CGFloat progressValue = self.state.animationStartValue + (self.state.animationEndValue - self.state.animationStartValue) * progress;
    CGPoint progressAlignShift = CGPointMake(self.state.animationInitialAlignShift.x + (self.layout.alignShift.x - self.state.animationInitialAlignShift.x) * linkProgress,
                                             self.state.animationInitialAlignShift.y + (self.layout.alignShift.y - self.state.animationInitialAlignShift.y) * linkProgress);
    
    for (UICounterLabel* child in self.children)
    {
        if (progressValue > child.state.animationEndValue)
            child.state = self.state;
        
        if (child.state == self.state)
            [child setNeedsDisplay];
    }
    
    // Draw wheel labels
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextRef maskedContext = UIGraphicsGetCurrentContext();
    CGImageRef mask = self.gradientMask;
    CGContextClipToMask(maskedContext, self.bounds, mask);
    
    UIImage* wheelImage = self.wheelImage;
    NSInteger wheelsCount = ((NSInteger)log10(MAX(1, self.maxDrawableValue))) + 1;
    NSArray* points = [self.class drawingPointsForCanvasOfSize:self.frame.size
                                                  wheelSpacing:self.layout.wheelCellSpacing
                                                    wheelCount:wheelsCount
                                                     fromValue:self.state.animationStartValue
                                                       toValue:self.state.animationEndValue
                                                    atProgress:progress];
    
    for (NSValue* pointObject in points)
    {
        CGPoint point = pointObject.CGPointValue;
        
        point.x += progressAlignShift.x;
        point.y += progressAlignShift.y;
        
        [wheelImage drawAtPoint:point];
    }
    
    CGContextRestoreGState(context);
    
    // Draw progress ring
    CGFloat arrowMinDrawnAngle = 2.0 * M_PI * 0.02;
    CGFloat arrowMaxFadeAngle = 2.0 * M_PI * 0.04;
    CGFloat arrowValue = MIN(0.98, progress * (CGFloat)self.state.animationEndValue / MAX(1, self.maxValue));
    CGFloat arrowAngle = arrowValue * 2.0 * M_PI;
    CGPoint arrowCenter = CGPointMake(self.bounds.size.width / 2.0 + self.layout.ringOffset.x, self.bounds.size.height / 2.0 + self.layout.ringOffset.y);
    CGFloat arrowRadius = INTERFACE_IS_PHONE ? 55.0 : 100.0;
    CGFloat arrowWidth = INTERFACE_IS_PHONE ? 2.0 : 4.0;
    CGFloat arrowArmLength = INTERFACE_IS_PHONE ? 6.0 : 12.0;
    CGFloat arrowLegLength = INTERFACE_IS_PHONE ? 4.0 : 8.0;
    CGFloat arrowArmAngle = M_PI_4;
    CGFloat arrowLegAngle = M_PI_2;
    CGFloat arrowArmWidth = INTERFACE_IS_PHONE ? 3.0 : 6.0;
    CGFloat arrowLegWidth = INTERFACE_IS_PHONE ? 2.0 : 4.0;
    CGFloat arrowHeadFade = MIN(1.0, (arrowAngle - arrowMinDrawnAngle) / (arrowMaxFadeAngle - arrowMinDrawnAngle));
    BOOL arrowHeadSkip = arrowAngle < arrowMinDrawnAngle;
    UIColor* ringColor = self.textColor;
    
    CGPoint arrowTail = CGPointMake(arrowCenter.x,
                                    arrowCenter.y - arrowRadius);
    CGPoint arrowRightLeg = CGPointMake(arrowTail.x + sin(-M_PI_2 - arrowLegAngle) * arrowLegLength,
                                        arrowTail.y + cos(-M_PI_2 - arrowLegAngle) * arrowLegLength);
    CGPoint arrowHead = CGPointMake(arrowCenter.x + sin(arrowAngle) * arrowRadius,
                                    arrowCenter.y - cos(arrowAngle) * arrowRadius);
    CGPoint arrowRightArm = CGPointMake(arrowHead.x + sin(-arrowAngle - M_PI_2 - arrowArmAngle) * arrowArmLength,
                                        arrowHead.y + cos(-arrowAngle - M_PI_2 - arrowArmAngle) * arrowArmLength);
    CGPoint arrowLeftArm = CGPointMake(arrowHead.x + sin(-arrowAngle - M_PI_2 + arrowArmAngle) * arrowArmLength,
                                       arrowHead.y + cos(-arrowAngle - M_PI_2 + arrowArmAngle) * arrowArmLength);
    
    if (self.layout.arrowDrawnParts != SNCounterLabelArrowPartNone)
    {
        [[UIColor colorWithWhite:1.0 alpha:0.1] setStroke];
        CGContextSetLineWidth(context, arrowWidth);
        CGContextBeginPath(context);
        CGContextAddArc(context, arrowCenter.x, arrowCenter.y, arrowRadius, 0, M_PI * 2.0, NO);
        CGContextStrokePath(context);
    }
    
    if (0 != (self.layout.arrowDrawnParts & SNCounterLabelArrowPartBody))
    {
        [ringColor setStroke];
        CGContextSetLineWidth(context, arrowWidth);
        CGContextBeginPath(context);
        CGContextAddArc(context, arrowCenter.x, arrowCenter.y, arrowRadius, -M_PI_2 + arrowAngle, -M_PI_2, YES);
        CGContextStrokePath(context);
    }
    
    if (0 != (self.layout.arrowDrawnParts & SNCounterLabelArrowPartTail))
    {
        [ringColor setStroke];
        CGContextSetLineWidth(context, arrowLegWidth);
        CGContextBeginPath(context);
        CGContextAddLine(context, arrowRightLeg, arrowTail);
        CGContextStrokePath(context);
    }
    
    if (0 != (self.layout.arrowDrawnParts & SNCounterLabelArrowPartHead) && !arrowHeadSkip)
    {
        [ringColor setStroke];
        CGContextSetLineWidth(context, arrowArmWidth * arrowHeadFade);
        CGContextBeginPath(context);
        CGContextAddLine(context, arrowRightArm, arrowHead);
        CGContextAddLine(context, arrowLeftArm, arrowHead);
        CGContextStrokePath(context);
    }
    
    if (0 != (self.layout.arrowDrawnParts & SNCounterLabelArrowPartTail))
    {
        [ringColor setFill];
        CGContextFillRing(context, arrowTail, arrowLegWidth);
        CGContextFillRing(context, arrowRightLeg, arrowLegWidth);
    }
    
    if (0 != (self.layout.arrowDrawnParts & (SNCounterLabelArrowPartBody | SNCounterLabelArrowPartHead)))
    {
        [ringColor setFill];
        CGContextFillRing(context, arrowHead, arrowArmWidth);
    }
    
    if (0 != (self.layout.arrowDrawnParts & SNCounterLabelArrowPartHead))
    {
        [ringColor setFill];
        
        if (!arrowHeadSkip)
        {
            CGContextFillRing(context, arrowRightArm, arrowArmWidth * arrowHeadFade);
            CGContextFillRing(context, arrowLeftArm, arrowArmWidth * arrowHeadFade);
        }
    }
    
    if (progress >= 1.0 && _animationCompletionBlock)
    {
        dispatch_block_t block = _animationCompletionBlock;
        _animationCompletionBlock = nil;
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
