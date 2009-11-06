/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Sindesso Pty Ltd http://www.sindesso.com/
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCTransition.h"

/**
 * A transition which peels back the bottom right hand corner of a scene
 * to transition to the scene beneath it simulating a page turn
 *
 * This uses a 3DAction so it's strongly recommended that depth buffering
 * is turned on in CCDirector using:
 *
 * 	[[CCDirector sharedDirector] setDepthBufferFormat:kDepthBuffer16]; 
 *
 * @since v0.8.2
 */
@interface CCPageTurnTransition : CCTransitionScene {
	BOOL	back_;
}

/**
 * creates a base transition with duration and incoming scene
 * if back is TRUE then the effect is reversed to appear as if the incoming 
 * scene is being turned from left over the outgoing scene
 */
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s backwards:(BOOL) back;

/**
 * creates a base transition with duration and incoming scene
 * if back is TRUE then the effect is reversed to appear as if the incoming 
 * scene is being turned from left over the outgoing scene
 */
-(id) initWithDuration:(ccTime) t scene:(CCScene*)s backwards:(BOOL) back;

-(CCIntervalAction*) actionWithSize:(ccGridSize) vector;

@end
