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
#import "TouchHandler.h"
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

/** Adds a touch handler to the dispatcher's list */
-(void) addHandler:(TouchHandler*) touchHandler;
/** Removes a touch handler. */
-(void) removeHandler:(TouchHandler *) touchHandler;
/** Convenience method that works on the delegate's corresponding handler */
-(void) removeHandlerForDelegate:(id) delegate;
/** Removes all touch handlers. */
-(void) removeAllHandlers;
/** Changes the priority of a previously added touch handler. The lower the number,
 the higher the priority */
-(void) setPriority:(int) priority forHandler:(TouchHandler *) touchHandler;
/** Convenience method that works on the delegate's corresponding handler */
-(void) setPriority:(int) priority forDelegate:(id) delegate;

@end
