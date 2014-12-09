//
//  NSGameplayManager.h
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSGameplayManager : NSObject

+ (instancetype)sharedManager;
- (NSUInteger)gameLaunchCount;
- (void)incrementGameLaunchCounter;

@end
