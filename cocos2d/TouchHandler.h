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
 XXX: add description
*/
@interface TouchHandler : NSObject {
	id<StandardTouchDelegate> delegate;
	int priority;
}

@property(nonatomic, readonly) id<StandardTouchDelegate> delegate;
@property(nonatomic, readwrite) int priority; // default 0

+ (id)handlerWithDelegate:(id<StandardTouchDelegate>) aDelegate;
- (id)initWithDelegate:(id<StandardTouchDelegate>) aDelegate;

@end
