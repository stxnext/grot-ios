//
//  SNMenuView.h
//  Grot
//
//  Created by Adam on 23.07.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SNNewGameButton.h"

@interface SNMenuView : SKShapeNode
{
    BOOL isHiden;
}

@property (nonatomic, strong) SNNewGameButton *level1Button;
@property (nonatomic, strong) SNNewGameButton *level2Button;
@property (nonatomic, strong) SNNewGameButton *level3Button;

- (void)toggle;

@end
