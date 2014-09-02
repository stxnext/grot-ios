//
//  SNFloatingMenu.h
//  Grot
//
//  Created by Dawid Żakowski on 20/08/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SNFloatingMenuOption) {
    SNFloatingMenuOptionResume,
    SNFloatingMenuOptionRestart,
    SNFloatingMenuOptionGameCenter,
    SNFloatingMenuOptionInstructions
};

@interface SNFloatingMenuController : UIViewController

@property (nonatomic, strong) void (^menuSelectionBlock)(SNFloatingMenuOption);

@property (nonatomic, strong) IBOutlet UIView* dimView;
@property (nonatomic, strong) IBOutlet UILabel* menuLabel;

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray* buttons;
@property (nonatomic, strong) IBOutlet UIButton* resumeButton;
@property (nonatomic, strong) IBOutlet UIButton* restartButton;
@property (nonatomic, strong) IBOutlet UIButton* gameCenterButton;
@property (nonatomic, strong) IBOutlet UIButton* instructionsButton;

@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray* labels;
@property (nonatomic, strong) IBOutlet UILabel* resumeLabel;
@property (nonatomic, strong) IBOutlet UILabel* restartLabel;
@property (nonatomic, strong) IBOutlet UILabel* gameCenterLabel;
@property (nonatomic, strong) IBOutlet UILabel* instructionsLabel;

+ (SNFloatingMenuController*)showMenuWithDecorator:(void (^)(SNFloatingMenuController* menu))decoratorBlock;

- (IBAction)selectMenuItem:(UIButton*)sender;
- (void)dismissWithCompletionHandler:(dispatch_block_t)completionBlock;

- (void)animate;

@end