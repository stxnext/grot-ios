//
//  SNNewGameButton.h
//  Grot
//
//  Created by Adam on 24.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>


typedef NS_ENUM(NSInteger, SNGameLevel) {
    SNGameLevelFast = 3,
    SNGameLevelMedium = 4,
    SNGameLevelSlow = 5
};


@interface SNNewGameButton : SKShapeNode

- (id)initWithLevel:(SNGameLevel)level;

@end
