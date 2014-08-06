//
//  SKObservableView.h
//  Grot
//
//  Created by Dawid Żakowski on 06/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol SKObservableViewDelegate <NSObject>

- (void)viewDidLayoutSubviews:(UIView*)view;

@end

@interface SKObservableView : SKView

@property (nonatomic, weak) id<SKObservableViewDelegate> delegate;

@end
