//
//  NSObject+SafeBlocks.h
//  Grot
//
//  Created by Dawid Żakowski on 28/11/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SafeBlocks)

+ (dispatch_block_t)performBlock:(void (^)(dispatch_block_t safeBlock))block;

@end
