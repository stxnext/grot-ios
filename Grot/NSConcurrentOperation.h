//
//  NSConcurrentOperation.h
//  Grot
//
//  Created by Dawid Żakowski on 08/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSConcurrentOperation : NSOperation
{
    BOOL _isExecuting;
    BOOL _isFinished;
    void (^_executionBlock)(dispatch_block_t callback);
}

+ (instancetype)concurrentOperationWithBlock:(void (^)(dispatch_block_t callback))block;

@end

@interface NSOperationQueue (NSConcurrentOperation)

- (void)addConcurrentOperationWithBlock:(void (^)(dispatch_block_t callback))block;
- (void)setPendingOperationsCompletionHandler:(dispatch_block_t)completionBlock;

@end