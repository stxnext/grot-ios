//
//  NSFieldTransition.h
//  Grot
//
//  Created by Dawid Żakowski on 15/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArrowField.h"

@interface NSFieldTransition : NSObject

@property (nonatomic, strong) NSArrowField* arrowField;
@property (nonatomic) CGPoint endpointPosition;

@end