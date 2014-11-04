//
//  SNPair.h
//  Grot
//
//  Created by Dawid Żakowski on 03/10/2014.
//  Copyright (c) 2014 STX Next. All rights reserved.
//

#ifndef Grot_SNPair_h
#define Grot_SNPair_h

#define SNPair_Apple(A, B)   (NSStringFromCGPoint((CGPoint){ A, B }).hash)
#define SNPair_Canton(A, B)  ((A + B) * (A + B + 1) / 2 + A)
#define SNPair_Szudzik(A, B) (A >= B ? A * A + A + B : A + B * B)
#define SNPair_Binary(A, B)  ((A << (sizeof(B) / 2)) | ((B << (sizeof(B) / 2)) >> (sizeof(B) / 2)))

#endif
