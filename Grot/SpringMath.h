//
//  SpringMath.h
//  Grot
//
//  Created by Dawid Żakowski on 14/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#include <stdbool.h>

double springValue(double time, double start, double end, double duration, double stiffness, int bounces, bool overshoot);