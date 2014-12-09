//
//  NSRemotePlayer.h
//  Grot
//
//  Created by Dawid Żakowski on 05/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRemotePlayer : NSObject
{
    NSInteger _cachedScore;
}

@property (nonatomic) NSInteger highScore;

- (void)refreshHighScore;
- (BOOL)isConnected;

@end