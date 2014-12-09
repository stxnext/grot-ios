//
//  NSUpdateManager.h
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUpdateManager : NSObject

+ (instancetype)sharedManager;

- (void)trigerApplicationUpdateEventsIfNeeded;

@end
