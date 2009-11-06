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

#import "CCTouchDelegateProtocol.h"
#import "Support/EAGLView.h"


/** CCTouchDispatcher.
 Singleton that handles all the touch events.
 The dispatcher dispatches events to the registered TouchHandlers.
 @since v0.8.0
 */
@interface CCTouchDispatcher : NSObject <EAGLTouchDelegate>
{
	NSMutableArray *touchHandlers;
	BOOL dispatchEvents;
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
