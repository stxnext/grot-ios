//
//  UIFloatingMenuController.m
//  Grot
//
//  Created by Dawid Żakowski on 18.11.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFloatingMenuController.h"
#import "UIFloatingHelpController.h"
#import "UIGameStoryboard.h"

@implementation UIFloatingMenuController

#pragma mark - View cycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.destinationViewController isKindOfClass:[UIFloatingHelpController class]])
    {
        __weak UIFloatingHelpController* weakMenu = (UIFloatingHelpController*)segue.destinationViewController;
        
        weakMenu.shouldAnimate = NO;
        
        weakMenu.menuButtonSelectionBlock = ^(UIFloatingHelpButtonTag option) {
            switch (option)
            {
                case UIFloatingHelpButtonReturnTag:
                {
                    weakMenu.shouldAnimate = YES;
                    self.shouldAnimate = NO;
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        self.shouldAnimate = YES;
                    }];
                    
                    break;
                }
            }
        };
    }
}

#pragma mark - Buttons data source

- (void)setupMenuButton:(UIMenuButton*)button
{
    switch ((UIFloatingMenuButtonTag)button.tag)
    {
        case UIFloatingMenuButtonResumeTag:
        {
            button.text = NSLocalizedString(@"Resume", nil);
            button.image = [UIImage imageNamed:@"ButtonCheck"];
            
            break;
        }
            
        case UIFloatingMenuButtonRestartTag:
        {
            button.text = NSLocalizedString(@"Restart", nil);
            button.image = [UIImage imageNamed:@"ButtonRestart"];
            
            break;
        }
            
        case UIFloatingMenuButtonGameCenterTag:
        {
            button.text = NSLocalizedString(@"Game Center", nil);
            button.image = [UIImage imageNamed:@"ButtonPad"];
            
            break;
        }
            
        case UIFloatingMenuButtonInstructionsTag:
        {
            button.text = NSLocalizedString(@"Instructions", nil);
            button.image = [UIImage imageNamed:@"ButtonHelp"];
            
            break;
        }
    }
}

- (NSUInteger)indexForMenuButton:(UIMenuButton*)button
{
    switch ((UIFloatingMenuButtonTag)button.tag)
    {
        case UIFloatingMenuButtonResumeTag: return 0;
        case UIFloatingMenuButtonRestartTag: return 1;
        case UIFloatingMenuButtonGameCenterTag: return 2;
        case UIFloatingMenuButtonInstructionsTag: return 3;
    }
}

@end