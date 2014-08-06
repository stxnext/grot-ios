//
//  SNGrotHints.h
//  Grot
//
//  Created by Dawid Żakowski on 06/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNGrotFieldModel.h"

@interface SNGameResults : NSObject

@property (nonatomic) NSUInteger score;
@property (nonatomic) NSUInteger moves;

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
- (BOOL)isEmptyRow:(NSUInteger)row;
- (BOOL)isEmptyColumn:(NSUInteger)column;
- (NSUInteger)longerSideLength;
- (NSUInteger)shorterSideLength;
- (NSUInteger)area;
- (BOOL)containsPoint:(CGPoint)point;

@end

@interface SNGrotGrid : SNGrid

- (SNGrotFieldModel*)grotPointedByGrot:(SNGrotFieldModel*)grot;
- (SNGameResults*)runGrot:(SNGrotFieldModel*)grot withGameResults:(SNGameResults*)currentResults;
- (void)fillHoles;

@end

@interface SNGrotHints : NSObject

+ (void)test;

@end
