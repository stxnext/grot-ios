//
//  SKObservableView.m
//  Grot
//
//  Created by Dawid Żakowski on 06/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "SKObservableView.h"

@implementation SKObservableView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.delegate viewDidLayoutSubviews:self];
}

@end
