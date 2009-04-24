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
#import "TargetedTouchDelegate.h"

/**
 TouchHandler
 XXX: add description
*/
@interface TouchHandler : NSObject {
@private
	id<TargetedTouchDelegate> delegate;
	int priority;
	BOOL swallowsTouches;
	NSMutableSet *claimedTouches;
}

@property(nonatomic, readonly) id<TargetedTouchDelegate> delegate;
@property(nonatomic, readwrite) int priority; // default 0
@property(nonatomic, readwrite) BOOL swallowsTouches; // default NO
@property(nonatomic, readonly) NSMutableSet *claimedTouches;

+ (id)handlerWithDelegate:(id<TargetedTouchDelegate>) aDelegate;
- (id)initWithDelegate:(id<TargetedTouchDelegate>) aDelegate;

@end
