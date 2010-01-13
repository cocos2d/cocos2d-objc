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
#import "CCTouchDispatcher.h"

/**
 CCTouchHandler
 Object than contains the delegate and priority of the event handler.
*/
@interface CCTouchHandler : NSObject {
	id				delegate;
	int				priority;
	ccTouchSelectorFlag		enabledSelectors_;
}

/** delegate */
@property(nonatomic, readwrite, retain) id delegate;
/** priority */
@property(nonatomic, readwrite) int priority; // default 0
/** enabled selectors */
@property(nonatomic,readwrite) ccTouchSelectorFlag enabledSelectors;

/** allocates a TouchHandler with a delegate and a priority */
+ (id)handlerWithDelegate:(id)aDelegate priority:(int)priority;
/** initializes a TouchHandler with a delegate and a priority */
- (id)initWithDelegate:(id)aDelegate priority:(int)priority;
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

/** allocates a TargetedTouchHandler with a delegate, a priority and whether or not it swallows touches or not */
+ (id)handlerWithDelegate:(id) aDelegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches;
/** initializes a TargetedTouchHandler with a delegate, a priority and whether or not it swallows touches or not */
- (id)initWithDelegate:(id) aDelegate priority:(int)priority swallowsTouches:(BOOL)swallowsTouches;

@end

