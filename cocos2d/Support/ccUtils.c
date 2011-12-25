/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 */

/*
 ccNextPOT function is licensed under the same license that is used in CCTexture2D.m.
 */
#include "ccUtils.h"

unsigned long ccNextPOT(unsigned long x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}
