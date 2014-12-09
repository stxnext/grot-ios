//
//  SpringMath.c
//  Grot
//
//  Created by Dawid Żakowski on 14/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#include "SpringMath.h"
#include <math.h>
#include <stdlib.h>

#define fOVS(a, b) (a ? b : (b >= 0 ? b : -b))

double springValue(double time, double start, double end, double duration, double stiffness, int bounces, bool overshoot)
{
    return start + ((start - end) * pow(M_E, -fabs(log2f(stiffness / fabsf(end - start))) * time) * fOVS(overshoot, cos((bounces + 1) * M_PI * time)) + end) * (end - start);
}