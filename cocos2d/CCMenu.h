/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "CCMenuItem.h"
#import "CCLayer.h"

typedef enum  {
	kCCMenuStateWaiting,
	kCCMenuStateTrackingTouch
} tCCMenuState;

enum {
	//* priority used by the menu for the event handler
	kCCMenuHandlerPriority = -128,
};

/** A CCMenu
 *
 * Features and Limitation:
 *  - You can add MenuItem objects in runtime using addChild:
 *  - But the only accecpted children are MenuItem objects
 */
@interface CCMenu : CCLayer <CCRGBAProtocol>
{
	tCCMenuState state_;
	CCMenuItem	*selectedItem_;
	GLubyte		opacity_;
	ccColor3B	color_;
	BOOL		enabled_;
}

/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) GLubyte opacity;
/** conforms to CCRGBAProtocol protocol */
@property (nonatomic,readonly) ccColor3B color;
/** whether or not the menu will receive events */
@property (nonatomic, readwrite) BOOL enabled;

/** creates a CCMenu with its items */
+ (id) menuWithItems: (CCMenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;

/** creates a CCMenu with a NSArray of CCMenuItem objects */
+ (id) menuWithArray:(NSArray*)arrayOfItems;

/** initializes a CCMenu with its items */
- (id) initWithItems: (CCMenuItem*) item vaList: (va_list) args;

/** initializes a CCMenu with a NSArray of CCMenuItem objects */
- (id) initWithArray:(NSArray*)arrayOfItems;

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

/** set event handler priority. By default it is: kCCMenuTouchPriority */
-(void) setHandlerPriority:(NSInteger)newPriority;

@end
