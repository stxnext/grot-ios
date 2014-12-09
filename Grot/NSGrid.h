//
//  NSGrid.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGPoint const NSGridInvalidPoint;

@interface NSGrid : NSObject<NSCopying>
{
    @private
    NSMutableDictionary* _items;
}

@property (nonatomic, assign, readonly) CGSize size;

- (instancetype)initWithSize:(CGSize)size;
- (NSArray*)allObjects;
- (id)objectAtPoint:(CGPoint)point;
- (CGPoint)pointForObject:(id)object;
- (void)setObject:(id)object atPoint:(CGPoint)point;
- (void)fillWithItems:(NSArray*)items;
- (void)pushDown;
- (BOOL)isEmptyRow:(NSInteger)row;
- (BOOL)isEmptyColumn:(NSInteger)column;
- (BOOL)containsPoint:(CGPoint)point;
- (NSInteger)longerSideLength;
- (NSInteger)shorterSideLength;
- (NSInteger)area;
- (NSGrid*)gridBySubtractingGrid:(NSGrid*)grid;

@end