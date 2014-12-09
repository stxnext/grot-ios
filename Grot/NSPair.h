//
//  NSPair.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#ifndef Grot_NSPair_h
#define Grot_NSPair_h

#define NSPair_Apple(A, B)   (NSStringFromCGPoint((CGPoint){ A, B }).hash)
#define NSPair_Canton(A, B)  ((A + B) * (A + B + 1) / 2 + A)
#define NSPair_Szudzik(A, B) (A >= B ? A * A + A + B : A + B * B)
#define NSPair_Binary(A, B)  ((A << (sizeof(B) / 2)) | ((B << (sizeof(B) / 2)) >> (sizeof(B) / 2)))

#endif
