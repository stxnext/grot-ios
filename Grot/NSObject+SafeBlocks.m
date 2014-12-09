//
//  NSObject+SafeBlocks.m
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSObject+SafeBlocks.h"

@implementation NSObject (SafeBlocks)

+ (dispatch_block_t)performBlock:(void (^)(dispatch_block_t safeBlock))block
{
    dispatch_block_t strongBlock;
    __weak __block dispatch_block_t weakBlock = strongBlock = ^{
        block(weakBlock);
    };
    strongBlock();
    return strongBlock;
}

@end
