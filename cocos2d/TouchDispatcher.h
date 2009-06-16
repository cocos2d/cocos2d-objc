/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

/** Adds a standard touch delegate to the dispatcher's list.
 See StandardTouchDelegate description. */
-(void) addStandardDelegate:(id<StandardTouchDelegate>) delegate priority:(int)priority;
/** Adds a targeted touch delegate to the dispatcher's list.
 See TargetedTouchDelegate description. */
-(void) addTargetedDelegate:(id<TargetedTouchDelegate>) delegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches;
/** Removes a touch delegate. */
-(void) removeDelegate:(id) delegate;
/** Removes all touch delegates. */
-(void) removeAllDelegates;
/** Changes the priority of a previously added delegate. The lower the number,
 the higher the priority */
-(void) setPriority:(int) priority forDelegate:(id) delegate;

@end
