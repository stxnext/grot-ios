//
//  SNGrotHints.h
//  Grot
//
//  Created by Dawid Żakowski on 06/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNGrotFieldModel.h"

@interface NSDictionary (Aggregation)

- (id)keyForMaxValueUsingValueComparator:(NSComparator)comparator;

@end

@interface SNGameResults : NSObject<NSCopying>

@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger moves;

+ (SNGameResults*)zeroResults;
- (void)add:(SNGameResults*)results;

@end

@interface SNGrid : NSObject<NSCopying>
{
    @private
    NSMutableDictionary* _items;
}

@property (nonatomic, assign, readonly) CGSize size;

- (instancetype)initWithSize:(CGSize)size;
- (id)objectAtPoint:(CGPoint)point;
- (void)setObject:(id)object atPoint:(CGPoint)point;
- (void)pushDown;
- (BOOL)isEmptyRow:(NSInteger)row;
- (BOOL)isEmptyColumn:(NSInteger)column;
- (NSInteger)longerSideLength;
- (NSInteger)shorterSideLength;
- (NSInteger)area;
- (BOOL)containsPoint:(CGPoint)point;

@end

@interface SNGrotGrid : SNGrid

- (SNGrotFieldModel*)grotPointedByGrot:(SNGrotFieldModel*)grot;
- (SNGameResults*)runReactionAtGrot:(SNGrotFieldModel*)grot gameResults:(SNGameResults*)currentResults;
- (void)fillWithRandoms;
- (void)fillWithItems:(NSArray*)items;

@end

@interface SNGameState : NSObject

@property (nonatomic, strong) SNGrotGrid* grid;
@property (nonatomic, strong) SNGameResults* results;

- (NSDictionary*)generatedStates;
- (NSDictionary*)generatedStateOptimizedForStatePropertyAtKeyPath:(NSString*)keyPath;
- (NSDictionary*)generatedStateOptimizedForMaxScore;
- (NSDictionary*)generatedStateOptimizedForMaxMoves;

@end