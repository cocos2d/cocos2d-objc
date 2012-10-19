/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
 * Copyright (c) 2011 Samuel J. Grabski
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

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/*
 * This file contains the delegates of the touches
 * There are 2 possible delegates:
 *   - CCStandardTouchHandler: propagates all the events at once
 *   - CCTargetedTouchHandler: propagates 1 event at the time
 */

#import "CCTouchDelegateProtocol.h"
#import "CCTouchDispatcher.h"

/**
 CCTouchHandler
 Object than contains the delegate and priority of the event handler.
 */
@interface CCTouchHandler : NSObject {
	id				delegate;
	int				priority;
	int 			tag;	// similar to CCNode tag
	int			disable;	// allows fast disabling: default NO, enabled
	BOOL         remove;    // if (!=0) object marked for removal (allows fast removal)
	ccTouchSelectorFlag		enabledSelectors_;
}

/** delegate */
@property(nonatomic, readwrite, retain) id delegate;
/** priority */
@property(nonatomic, readwrite) int priority;	// default 0
/** tag */
@property(nonatomic, readwrite) int tag; 		// default 0
/** disable */
@property(nonatomic, readwrite) int disable; 	// default 0; NO
/** remove */
@property(nonatomic, readwrite) BOOL remove;	// default NO

/** enabled selectors */
@property(nonatomic,readwrite) ccTouchSelectorFlag enabledSelectors;

/** allocates a TouchHandler with a delegate and a priority */
+ (id)handlerWithDelegate:(id)aDelegate priority:(int)priority;
/** initializes a TouchHandler with a delegate and a priority */
- (id)initWithDelegate:(id)aDelegate priority:(int)priority;

/** allocates a TouchHandler with a delegate, priority, tag and a disable flag */
+ (id)handlerWithDelegate:(id)aDelegate priority:(int)aPriority tag:(int)aTag disable:(int)yesOrNo;
/** initializes a TouchHandler with a delegate, priority tag and a disable flag */
- (id)initWithDelegate:(id)aDelegate priority:(int)aPriority tag:(int)aTag disable:(int)yesOrNo;
@end

/** CCStandardTouchHandler
 It forwardes each event to the delegate.
 */
@interface CCStandardTouchHandler : CCTouchHandler
{
}
@end

/**
 CCTargetedTouchHandler
 Object than contains the claimed touches and if it swallos touches.
 Used internally by TouchDispatcher
 */
@interface CCTargetedTouchHandler : CCTouchHandler {
	BOOL swallowsTouches;
	NSMutableSet *claimedTouches;
}
/** whether or not the touches are swallowed */
@property(nonatomic, readwrite) BOOL swallowsTouches; // default NO
/** MutableSet that contains the claimed touches */
@property(nonatomic, readonly) NSMutableSet *claimedTouches;

/** allocates a TargetedTouchHandler with a delegate, a priority and whether or not it swallows touches or not
 tag = 0; disabled = NO
 */
+ (id)handlerWithDelegate:(id) aDelegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches;
/** allocates a TargetedTouchHandler with a delegate, a priority and whether or not it swallows touches or not
 allows to set tag and disabled flag
 */
+ (id)handlerWithDelegate:(id) aDelegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches
                      tag:(int)aTag disable:(int)yesOrNo;
/** initializes a TargetedTouchHandler with a delegate, a priority and whether or not it swallows touches or not */
- (id)initWithDelegate:(id) aDelegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches;

/** initializes a TargetedTouchHandler with a delegate, a priority and whether or not it swallows touches or not
 allows to set tag and disabled flag
 */
- (id)initWithDelegate:(id) aDelegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches
                   tag:(int)aTag disable:(int)yesOrNo;
@end

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
