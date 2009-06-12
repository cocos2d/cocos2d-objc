/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2009 Valentin Milea
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <UIKit/UIKit.h>
#import "Layer.h"
#import "TouchDelegateProtocol.h"
#import "Support/EAGLView.h"


/** TouchDispatcher.
 Singleton that handles all the touch events.
 The dispatcher dispatches events to the registered TouchHandlers.
 @since v0.8
 */
@interface TouchDispatcher : NSObject <EAGLTouchDelegate>
{
	NSMutableArray *touchHandlers;
	BOOL dispatchEvents;
}

/** singleton of the TouchDispatcher */
+ (TouchDispatcher*)sharedDispatcher;

/** Whether or not the events are going to be dispatched. Default: YES */
@property (readwrite, assign) BOOL dispatchEvents;

/** Adds an "standard" delegate to the list of multi-touch event handlers, with priority 0 */
-(void) addStandardEventHandler:(id<StandardTouchDelegate>) delegate;
/** Adds an standard delegate to the list of multi-touch event handlers with a given priority.
 The lower the number, the higher the priority.
 */
-(void) addStandardEventHandler:(id<StandardTouchDelegate>) delegate priority:(int) priority;

/** Adds a targeted delegate to the list of multi-touch event handlers, with priority 0
 and touch swallowing on. */
-(void) addTargetedEventHandler:(id<TargetedTouchDelegate>) delegate;
/** Adds a targeted delegate to the list of multi-touch event handlers with a priority.
 The lower the number, the higher the priority.
 If a handler swallows touches, it will be the exclusive owner of the touch(es)
 it claims. Not swallowing allows other handlers to claim and receive updates on
 the same touch. */
-(void) addTargetedEventHandler:(id<TargetedTouchDelegate>) delegate
			   priority:(int) priority swallowTouches:(BOOL) swallowTouches;
/** Changes the priority of a previously added event handler. The lower the number,
 the higher the priority */
-(void) setPriority:(int) priority forEventHandler:(id) delegate;
/** Removes a delegate from the list of multi-touch event handlers. */
-(void) removeEventHandler:(id) delegate;
/** Removes all multi-touch event handlers. */
-(void) removeAllEventHandlers;

@end
