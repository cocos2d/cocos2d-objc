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

#import "CCPageTurnTransition.h"
#import	"CCPageTurn3DAction.h"
#import "CCDirector.h"

@implementation CCPageTurnTransition

/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s backwards:(BOOL) back
{
	return [[[self alloc] initWithDuration:t scene:s backwards:back] autorelease];
}

/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(ccTime) t scene:(CCScene*)s backwards:(BOOL) back
{
	// XXX: needed before [super init]
	back_ = back;

	if( ( self = [super initWithDuration:t scene:s] ) )
	{
		// do something
	}
	return self;
}

-(void) sceneOrder
{
	inSceneOnTop = back_;
}

//
-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	int x,y;
	if( s.width > s.height)
	{
		x=16;y=12;
	}
	else
	{
		x=12;y=16;
	}
	
	id action  = [self actionWithSize:ccg(x,y)];
	
	if(! back_ )
	{
		[outScene runAction: [CCSequence actions:
							  action,
							  [CCCallFunc actionWithTarget:self selector:@selector(finish)],
							  [CCStopGrid action],
							  nil]
		 ];
	}
	else
	{
		// to prevent initial flicker
		inScene.visible = NO;
		[inScene runAction: [CCSequence actions:
							 [CCShow action],
							 action,
							 [CCCallFunc actionWithTarget:self selector:@selector(finish)],
							 [CCStopGrid action],
							 nil]
		 ];
	}
	
}

-(CCIntervalAction*) actionWithSize: (ccGridSize) v
{
	if( back_ )
	{
		// Get hold of the PageTurn3DAction
		return [CCReverseTime actionWithAction:
				[CCPageTurn3D actionWithSize:v duration:duration]];
	}
	else
	{
		// Get hold of the PageTurn3DAction
		return [CCPageTurn3D actionWithSize:v duration:duration];
	}
}

@end

