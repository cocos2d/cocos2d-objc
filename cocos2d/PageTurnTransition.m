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

#import "PageTurnTransition.h"
#import	"PageTurn3DAction.h"
#import "Director.h"

@implementation PageTurnTransition

/** creates a base transition with duration and incoming scene */
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s backwards:(BOOL) back
{
	return [[[PageTurnTransition alloc] initWithDuration:t scene:s backwards:back] autorelease];
}

/** initializes a transition with duration and incoming scene */
-(id) initWithDuration:(ccTime) t scene:(Scene*)s backwards:(BOOL) back
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
	
	CGSize s = [[Director sharedDirector] winSize];
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
		[outScene runAction: [Sequence actions:
							  action,
							  [CallFunc actionWithTarget:self selector:@selector(finish)],
							  [StopGrid action],
							  nil]
		 ];
	}
	else
	{
		// to prevent initial flicker
		inScene.visible = NO;
		[inScene runAction: [Sequence actions:
							 [Show action],
							 action,
							 [CallFunc actionWithTarget:self selector:@selector(finish)],
							 [StopGrid action],
							 nil]
		 ];
	}
	
}

-(IntervalAction*) actionWithSize: (ccGridSize) v
{
	if( back_ )
	{
		// Get hold of the PageTurn3DAction
		return [ReverseTime actionWithAction:
				[PageTurn3DAction actionWithSize:v duration:duration]];
	}
	else
	{
		// Get hold of the PageTurn3DAction
		return [PageTurn3DAction actionWithSize:v duration:duration];
	}
}

@end

