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

#import <UIKit/UIKit.h>

#import "MenuItem.h"
#import "Layer.h"

typedef enum  {
	kMenuStateWaiting,
	kMenuStateTrackingTouch
} MenuState;

/** A Menu
 * 
 * Features and Limitation:
 *  - You can add MenuItem objects in runtime using addChild:
 *  - But the only accecpted children are MenuItem objects
 */
@interface Menu : Layer <CocosNodeRGBA>
{
	MenuState state;
	MenuItem *selectedItem;
	GLubyte opacity_, r_, g_, b_;
}

/** creates a menu with it's items */
+ (id) menuWithItems: (MenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

/** initializes a menu with it's items */
- (id) initWithItems: (MenuItem*) item vaList: (va_list) args;

/** align items vertically */
-(void) alignItemsVertically;
/** align items vertically with padding
 @since v0.7.2
 */
-(void) alignItemsVerticallyWithPadding:(float) padding;

/** align items horizontally */
-(void) alignItemsHorizontally;
/** align items horizontally with padding
 @since v0.7.2
 */
-(void) alignItemsHorizontallyWithPadding: (float) padding;


/** align items in rows of columns */
-(void) alignItemsInColumns: (NSNumber *) columns, ... NS_REQUIRES_NIL_TERMINATION;
-(void) alignItemsInColumns: (NSNumber *) columns vaList: (va_list) args;

/** align items in columns of rows */
-(void) alignItemsInRows: (NSNumber *) rows, ... NS_REQUIRES_NIL_TERMINATION;
-(void) alignItemsInRows: (NSNumber *) rows vaList: (va_list) args;


/** conforms to CocosNodeRGBA protocol */
@property (readonly) GLubyte opacity, r, g, b;

@end
