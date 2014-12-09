//
//  NSGameResults.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSGameResults : NSObject<NSCopying>

@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger moves;

+ (NSGameResults*)unknownResults;
+ (NSGameResults*)zeroResults;

- (void)add:(NSGameResults*)results;
- (void)subtract:(NSGameResults*)results;

@end
