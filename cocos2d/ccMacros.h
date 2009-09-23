/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <math.h>

/**
 @file
 cocos2d helper macros
 */

#if COCOS2D_DEBUG
//#define CCLOG(s, …) NSLog((@”%s %s:%d ” s), __func__, basename(__FILE__), __LINE__, ## __VA_ARGS__);
#define CCLOG(...) NSLog(__VA_ARGS__)
#else
#define CCLOG(...) do {} while (0)
#endif

//simple macro that swaps 2 variables
#define CC_SWAP( x, y )			\
({ __typeof__(x) temp  = (x);		\
		x = y; y = temp;		\
})




/// returns a random float between -1 and 1
#define CCRANDOM_MINUS1_1() ((random() / (float)0x3fffffff )-1.0f)

/// returns a random float between 0 and 1
#define CCRANDOM_0_1() ((random() / (float)0x7fffffff ))

/// converts degrees to radians
#define CC_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0f * (float)M_PI)

/// converts radians to degrees
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (float)M_PI * 180.0f)

/// default gl blend src function
//#define CC_BLEND_SRC GL_SRC_ALPHA
#define CC_BLEND_SRC GL_ONE
/// default gl blend dst function
#define CC_BLEND_DST GL_ONE_MINUS_SRC_ALPHA

