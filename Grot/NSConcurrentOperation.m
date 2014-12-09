//
//  NSConcurrentOperation.m
//  Grot
//
//  Created by Dawid Żakowski on 08/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "NSConcurrentOperation.h"

@implementation NSConcurrentOperation

- (instancetype)initWithBlock:(void (^)(dispatch_block_t callback))block
{
    self = [super init];
    
    if (self)
    {
        _isExecuting = NO;
        _isFinished = NO;
        _executionBlock = block;
    }
    
    return self;
}

+ (instancetype)concurrentOperationWithBlock:(void (^)(dispatch_block_t))block
{
    return [[self.class alloc] initWithBlock:block];
}

- (void)start
{
    [self operationDidStart];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _executionBlock(^{
            [self operationDidFinish];
        });
    });
}

- (void)operationDidStart
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)operationDidFinish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (BOOL)isFinished
{
    return _isFinished;
}

- (BOOL)concurrent
{
    return YES;
}

- (BOOL)asynchronous
{
    return YES;
}

@end

@implementation NSOperationQueue (NSConcurrentOperation)

- (void)addConcurrentOperationWithBlock:(void (^)(dispatch_block_t callback))block
{
    NSConcurrentOperation* operation = [NSConcurrentOperation concurrentOperationWithBlock:block];
    [self addOperation:operation];
}

- (void)setPendingOperationsCompletionHandler:(dispatch_block_t)completionBlock
{
    NSBlockOperation* completionOperation = [NSBlockOperation blockOperationWithBlock:completionBlock];
    
    for (NSOperation* operation in self.operations)
    {
        [completionOperation addDependency:operation];
    }
    
    [self addOperation:completionOperation];
}

@end
