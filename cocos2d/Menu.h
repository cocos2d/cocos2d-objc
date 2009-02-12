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

#import <UIKit/UIKit.h>

#import "MenuItem.h"
#import "Layer.h"

/** A Menu */
@interface Menu : Layer <CocosNodeOpacity>
{
	int selectedItem;
	GLubyte opacity;
}

/** creates a menu with it's items */
+ (id) menuWithItems: (MenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

/** initializes a menu with it's items */
- (id) initWithItems: (MenuItem*) item vaList: (va_list) args;

/** align items vertically */
-(void) alignItemsVertically;

/** align items horizontally */
-(void) alignItemsHorizontally;

@property (readwrite,assign) GLubyte opacity;

@end
