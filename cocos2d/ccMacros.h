/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
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

#ifdef DEBUG
//#define CCLOG(s, …) NSLog((@”%s %s:%d ” s), __func__, basename(__FILE__), __LINE__, ## __VA_ARGS__);
#define CCLOG(...) NSLog(__VA_ARGS__)
#else
#define CCLOG(...) do {} while (0)
#endif


/// returns a random float between -1 and 1
#define CCRANDOM_FLOAT_MINUS1_1() ((random() / (float)0x3fffffff )-1.0f)

/// returns a random float between 0 and 1
#define CCRANDOM_FLOAT_0_1() ((random() / (float)0x7fffffff ))
