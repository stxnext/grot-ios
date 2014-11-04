//
//  UIColor+Parser.h
//  Grot
//
//  Created by Dawid Żakowski on 08/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#ifndef Grot_UIColor_Parser_h
#define Grot_UIColor_Parser_h

#define ColorFromHex(hex) ([UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0 \
                                           green:((hex >> 8)  & 0xFF) / 255.0 \
                                            blue:((hex >> 0)  & 0xFF) / 255.0 \
                                           alpha:1.0])

#endif
