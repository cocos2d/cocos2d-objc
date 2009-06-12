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
#import "TouchDelegateProtocol.h"
#import "Support/EAGLView.h"

/**
 TouchHandler
 Object than contains the delegate and priority of the event handler.
 Used internally by TouchDispatcher
*/
@interface TouchHandler : NSObject {
	id delegate;
	int priority;
}

@property(nonatomic, readonly) id delegate;
@property(nonatomic, readwrite) int priority; // default 0

+ (id)handlerWithDelegate:(id) aDelegate;
- (id)initWithDelegate:(id) aDelegate;

- (BOOL)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

/** StandardTouchHandler
 */
@interface StandardTouchHandler : TouchHandler
{
}
@end

/**
 TargetedTouchHandler
 Object than contains the claimed touches and if it swallos touches.
 Used internally by TouchDispatcher
 */
@interface TargetedTouchHandler : TouchHandler {
	BOOL swallowsTouches;
	NSMutableSet *claimedTouches;
}
@property(nonatomic, readwrite) BOOL swallowsTouches; // default NO
@property(nonatomic, readonly) NSMutableSet *claimedTouches;
@end

