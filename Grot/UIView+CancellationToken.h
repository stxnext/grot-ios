//
//  UIView+CancellationToken.h
//  Grot
//
//  Created by Dawid Żakowski on 01/12/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSCancellationToken.h"

@interface UIView (CancellationToken)

@property (nonatomic) NSCancellationToken* cancellationToken;

@end
