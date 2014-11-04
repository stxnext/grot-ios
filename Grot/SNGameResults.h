//
//  SNGameResults.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNGameResultsObserver <NSObject>

@required
- (void)gameResultsScoreDidChange:(NSInteger)score;
- (void)gameResultsMovesDidChange:(NSInteger)moves;

@end

@interface SNGameResults : NSObject<NSCopying>

@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger moves;

@property (nonatomic, weak) id<SNGameResultsObserver> observer;

+ (SNGameResults*)unknownResults;
+ (SNGameResults*)zeroResults;

- (void)add:(SNGameResults*)results;

@end
