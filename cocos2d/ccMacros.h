//
//  cocos2dMacros.h
//  cocos2d-iphone
//
//  Created by Ricardo Quesada on 30/01/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//

#ifdef DEBUG
//#define CCLOG(s, …) NSLog((@”%s %s:%d ” s), __func__, basename(__FILE__), __LINE__, ## __VA_ARGS__);
#define CCLOG(...) NSLog(__VA_ARGS__)
#else
#define CCLOG(...) do {} while (0)
#endif