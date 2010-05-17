/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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


#import "CCTouchDelegateProtocol.h"
#import "Support/EAGLView.h"


typedef enum
{
	ccTouchSelectorBeganBit = 1 << 0,
	ccTouchSelectorMovedBit = 1 << 1,
	ccTouchSelectorEndedBit = 1 << 2,
	ccTouchSelectorCancelledBit = 1 << 3,
	ccTouchSelectorAllBits = ( ccTouchSelectorBeganBit | ccTouchSelectorMovedBit | ccTouchSelectorEndedBit | ccTouchSelectorCancelledBit),
} ccTouchSelectorFlag;


enum {
	ccTouchBegan,
	ccTouchMoved,
	ccTouchEnded,
	ccTouchCancelled,
	
	ccTouchMax,
};

struct ccTouchHandlerHelperData {
	SEL				touchesSel;
	SEL				touchSel;
	ccTouchSelectorFlag  type;
};

/** CCTouchDispatcher.
 Singleton that handles all the touch events.
 The dispatcher dispatches events to the registered TouchHandlers.
 There are 2 different type of touch handlers:
   - Standard Touch Handlers
   - Targeted Touch Handlers
 
 The Standard Touch Handlers work like the CocoaTouch touch handler: a set of touches is passed to the delegate.
 On the other hand, the Targeted Touch Handlers only receive 1 touch at the time, and they can "swallow" touches (avoid the propagation of the event).
 
 Firstly, the dispatcher sends the received touches to the targeted touches.
 These touches can be swallowed by the Targeted Touch Handlers. If there are still remaining touches, then the remaining touches will be sent
 to the Standard Touch Handlers.

 @since v0.8.0
 */
@interface CCTouchDispatcher : NSObject <EAGLTouchDelegate>
{
	NSMutableArray	*targetedHandlers;
	NSMutableArray	*standardHandlers;

	BOOL			locked;
	BOOL			toAdd;
	BOOL			toRemove;
	NSMutableArray	*handlersToAdd;
	NSMutableArray	*handlersToRemove;
	BOOL			toQuit;

	BOOL	dispatchEvents;
	
	// 4, 1 for each type of event
	struct ccTouchHandlerHelperData handlerHelperData[ccTouchMax];
}

/** singleton of the CCTouchDispatcher */
+ (CCTouchDispatcher*)sharedDispatcher;

/** Whether or not the events are going to be dispatched. Default: YES */
@property (nonatomic,readwrite, assign) BOOL dispatchEvents;

/** Adds a standard touch delegate to the dispatcher's list.
 See StandardTouchDelegate description.
 IMPORTANT: The delegate will be retained.
 */
-(void) addStandardDelegate:(id<CCStandardTouchDelegate>) delegate priority:(int)priority;
/** Adds a targeted touch delegate to the dispatcher's list.
 See TargetedTouchDelegate description.
 IMPORTANT: The delegate will be retained.
 */
-(void) addTargetedDelegate:(id<CCTargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches;
/** Removes a touch delegate.
 The delegate will be released
 */
-(void) removeDelegate:(id) delegate;
/** Removes all touch delegates, releasing all the delegates */
-(void) removeAllDelegates;
/** Changes the priority of a previously added delegate. The lower the number,
 the higher the priority */
-(void) setPriority:(int) priority forDelegate:(id) delegate;

@end
