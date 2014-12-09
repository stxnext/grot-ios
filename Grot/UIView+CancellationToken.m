//
//  UIView+CancellationToken.m
//  Grot
//
//  Created by Dawid Żakowski on 01/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIView+CancellationToken.h"
#import <objc/runtime.h>

@implementation UIView (CancellationToken)

- (void)setCancellationToken:(NSCancellationToken *)cancellationToken
{
    objc_setAssociatedObject(self, @selector(cancellationToken), cancellationToken, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSCancellationToken*)cancellationToken
{
    return objc_getAssociatedObject(self, @selector(cancellationToken));
}

@end
