//
//  SNFieldTransition.h
//  Grot
//
//  Created by Dawid Żakowski on 15/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNArrowField.h"

@interface SNFieldTransition : NSObject

@property (nonatomic, strong) SNArrowField* arrowField;
@property (nonatomic) CGPoint endpointPosition;

@end