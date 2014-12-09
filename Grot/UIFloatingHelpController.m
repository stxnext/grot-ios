//
//  UIFloatingHelpController.m
//  Grot
//
//  Created by Dawid Żakowski on 18.11.2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import "UIFloatingHelpController.h"
#import "UIView+RoundedEdges.h"
#import "NSArrowField.h"
#import "NSAnalyticsManager.h"

typedef NS_ENUM(NSUInteger, UIFloatingHelpFieldTag) {
    UIFloatingHelpFieldTag1,
    UIFloatingHelpFieldTag2,
    UIFloatingHelpFieldTag3,
    UIFloatingHelpFieldTag4
};

@implementation UIFloatingHelpController

#pragma mark - View cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (UIFieldBadge* badge in self.badges)
    {
        UIFloatingHelpFieldTag tag = badge.superview.tag;
        badge.type = [self.class badgeTypeForFieldTag:tag];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [NSAnalyticsManager.sharedManager helpDidShow];
}

+ (NSArrowFieldType)badgeTypeForFieldTag:(UIFloatingHelpFieldTag)tag
{
    switch (tag)
    {
        case UIFloatingHelpFieldTag1: return NSArrowFieldTypeLowest;
        case UIFloatingHelpFieldTag2: return NSArrowFieldTypeLow;
        case UIFloatingHelpFieldTag3: return NSArrowFieldTypeeHigh;
        case UIFloatingHelpFieldTag4: return NSArrowFieldTypeHighest;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    UIViewController* controller = segue.destinationViewController;
    
    if ([controller.view isKindOfClass:[UIFieldBadge class]])
    {
        // Badges setup
        UIFieldBadge* badge = (UIFieldBadge*)controller.view;
        
        NSArray* badges = self.badges ?: [NSArray array];
        badges = [badges arrayByAddingObject:badge];
        self.badges = badges;
    }
}

#pragma mark - Buttons data source

- (void)setupMenuButton:(UIMenuButton*)button
{
    switch ((UIFloatingHelpButtonTag)button.tag)
    {
        case UIFloatingHelpButtonReturnTag:
        {
            button.text = NSLocalizedString(@"Return", nil);
            button.image = [UIImage imageNamed:@"ButtonRestart"];
            
            break;
        }
    }
}

- (NSUInteger)indexForMenuButton:(UIMenuButton*)button
{
    switch ((UIFloatingHelpButtonTag)button.tag)
    {
        case UIFloatingHelpButtonReturnTag: return 0;
    }
}

@end
