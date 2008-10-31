/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import "Transition.h"
#import "CocosNode.h"
#import "Director.h"
#import "IntervalAction.h"
#import "InstantAction.h"
#import "CameraAction.h"
#import "Layer.h"
#import "Camera.h"

@implementation TransitionScene
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s
{
	return [[[self alloc] initWithDuration:t scene:s] autorelease];
}

-(id) initWithDuration:(ccTime) t scene:(Scene*)s
{
	NSAssert( s != nil, @"Argument scene must be non-nil");
	
	if( ! [super init] )
		return nil;
	
	duration = t;
	
	// Don't retain them, it will be reatined when added
	inScene = s;
	outScene = [[Director sharedDirector] runningScene];
	
	if( inScene == outScene ) {
		NSException* myException = [NSException
									exceptionWithName:@"TransitionWithInvalidScene"
									reason:@"Incoming scene must be different from the outgoing scene"
									userInfo:nil];
		@throw myException;		
	}
	
	// disable events while transitions
	[[Director sharedDirector] setEventsEnabled: NO];

	// add both scenes
	[self add: inScene z:1];
	[self add: outScene z:0];
	
	return self;
}

-(void) step: (ccTime) dt {

	[self unschedule:_cmd];
	
	[[Director sharedDirector] replaceScene: inScene];

	// enable events while transitions
	[[Director sharedDirector] setEventsEnabled: YES];
	
	[self remove: inScene];
	[self remove: outScene];
	
	inScene = nil;
	outScene = nil;
}

-(void) finish
{
	/* clean up */	
	[inScene setVisible:YES];
	[inScene setPosition:cpv(0,0)];
	[inScene setScale:1.0f];
	[inScene setRotation:0.0f];
	[inScene.camera restore];
	
	[outScene setVisible:NO]; // SJI
//	[outScene setVisible:YES];
	[outScene setPosition:cpv(0,0)];
	[outScene setScale:1.0f];
	[outScene setRotation:0.0f];
	[outScene.camera restore];
	
//	[inScene stopAllActions];
//	[outScene stopAllActions];

	[self schedule:@selector(step:) interval:0];
}
@end

//
// Oriented Transition
//
@implementation OrientedTransitionScene
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s orientation:(tOrientation)o
{
	return [[[self alloc] initWithDuration:t scene:s orientation:o] autorelease];
}

-(id) initWithDuration:(ccTime) t scene:(Scene*)s orientation:(tOrientation)o
{
	if( ! [super initWithDuration:t scene:s] )
		return nil;
	orientation = o;
	return self;
}
@end


//
// RotoZoom
//
@implementation RotoZoomTransition
-(void) onEnter
{
	[super onEnter];
	CGRect s = [[Director sharedDirector] winSize];
	
	[inScene setScale:0.001f];
	[outScene setScale:1.0f];
	
	[inScene setTransformAnchor: cpv( s.size.width/2, s.size.height/2) ];
	[outScene setTransformAnchor: cpv( s.size.width/2, s.size.height/2) ];
	
	IntervalAction *rotozoom = [Sequence actions: [Spawn actions:
								   [ScaleBy actionWithDuration:duration/2 scale:0.001f],
								   [RotateBy actionWithDuration:duration/2 angle:360 *2],
								   nil],
								[DelayTime actionWithDuration:duration/2],
							nil];
	
	
	[outScene do: rotozoom];
	[inScene do: [Sequence actions:
					[rotozoom reverse],
					[CallFunc actionWithTarget:self selector:@selector(finish)],
				  nil]];
}
@end

//
// JumpZoom
//
@implementation JumpZoomTransition
-(void) onEnter
{
	[super onEnter];
	CGRect s = [[Director sharedDirector] winSize];
	
	[inScene setScale:0.5f];
	[inScene setPosition:cpv( s.size.width,0 )];
	
	[inScene setTransformAnchor: cpv( s.size.width/2, s.size.height/2) ];
	[outScene setTransformAnchor: cpv( s.size.width/2, s.size.height/2) ];

	IntervalAction *jump = [JumpBy actionWithDuration:duration/4 position:cpv(-s.size.width,0) height:s.size.width/4 jumps:2];
	IntervalAction *scaleIn = [ScaleTo actionWithDuration:duration/4 scale:1.0f];
	IntervalAction *scaleOut = [ScaleTo actionWithDuration:duration/4 scale:0.5f];
	
	IntervalAction *jumpZoomOut = [Sequence actions: scaleOut, jump, nil];
	IntervalAction *jumpZoomIn = [Sequence actions: jump, scaleIn, nil];
	
	IntervalAction *delay = [DelayTime actionWithDuration:duration/2];
	
	[outScene do: jumpZoomOut];
	[inScene do: [Sequence actions: delay,
								jumpZoomIn,
								[CallFunc actionWithTarget:self selector:@selector(finish)],
								nil] ];
}
@end

//
// MoveInL
//
@implementation MoveInLTransition
-(void) onEnter
{
	[super onEnter];
	
	[self initScenes];
	
	IntervalAction *a = [self action];

	[inScene do: [Sequence actions:
		[Accelerate actionWithAction:a rate:0.5],
		[CallFunc actionWithTarget:self selector:@selector(finish)],
		nil] ];
	 		
}
-(IntervalAction*) action
{
	return [MoveTo actionWithDuration:duration position:cpv(0,0)];
}

-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: cpv( -s.size.width,0) ];
}
@end

//
// MoveInR
//
@implementation MoveInRTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: cpv( s.size.width,0) ];
}
@end

//
// MoveInT
//
@implementation MoveInTTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: cpv( 0, s.size.height) ];
}
@end

//
// MoveInB
//
@implementation MoveInBTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: cpv( 0, -s.size.height) ];
}
@end

//
// SlideInL
//
@implementation SlideInLTransition
-(void) onEnter
{
	[super onEnter];

	[self initScenes];
	
	IntervalAction *in = [self action];
	IntervalAction *out = [in copy];

	[inScene do: [Accelerate actionWithAction:in rate:0.5] ];
	[outScene do: [Sequence actions:
				   [Accelerate actionWithAction:out rate:0.5],
				   [CallFunc actionWithTarget:self selector:@selector(finish)],
				   nil] ];
	
	[out release];
}

-(IntervalAction*) action
{
	CGRect s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration position:cpv(s.size.width,0)];
}

-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: cpv( -s.size.width,0) ];
}
@end

//
// SlideInR
//
@implementation SlideInRTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: cpv( s.size.width,0) ];
}

-(IntervalAction*) action
{
	CGRect s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration position:cpv(-s.size.width,0)];
}

@end

//
// SlideInT
//
@implementation SlideInTTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: cpv(0,s.size.height) ];
}

-(IntervalAction*) action
{
	CGRect s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration position:cpv(0,-s.size.height)];
}

@end

//
// SlideInB
//
@implementation SlideInBTransition
-(void) initScenes
{
	CGRect s = [[Director sharedDirector] winSize];
	[inScene setPosition: cpv(0,-s.size.height) ];
}

-(IntervalAction*) action
{
	CGRect s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration position:cpv(0,s.size.height)];
}
@end

//
// ShrinkGrow Transition
//
@implementation ShrinkGrowTransition
-(void) onEnter
{
	[super onEnter];
	
	CGRect s = [[Director sharedDirector] winSize];
	
	[inScene setScale:0.001f];
	[outScene setScale:1.0f];
	
	[inScene setTransformAnchor:cpv(2*s.size.width/3,s.size.height/2) ];
	[outScene setTransformAnchor:cpv(s.size.width/3,s.size.height/2) ];
	
	
	IntervalAction *scaleOut = [ScaleTo actionWithDuration:duration scale:0.01f];
	IntervalAction *scaleIn = [ScaleTo actionWithDuration:duration scale:1.0f];

	[inScene do: [Accelerate actionWithAction:scaleIn rate:0.5] ];
	[outScene do: [Sequence actions:
					[Accelerate actionWithAction:scaleOut rate:0.5],
					[CallFunc actionWithTarget:self selector:@selector(finish)],
					nil] ];
}
@end

//
// FlipX Transition
//
@implementation FlipXTransition
-(void) onEnter
{
	[super onEnter];
	
	IntervalAction *inA, *outA;
	[inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kOrientationRightOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
	inA = [Sequence actions:
		   [DelayTime actionWithDuration:duration/2],
		   [Show action],
		   [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:0 deltaAngleX:0],
		   [CallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [Sequence actions:
			[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:0 deltaAngleX:0],
			[Hide action],
			[DelayTime actionWithDuration:duration/2],							
			nil ];
	
	[inScene do: inA];
	[outScene do: outA];
	
}
@end

//
// FlipY Transition
//
@implementation FlipYTransition
-(void) onEnter
{
	[super onEnter];
	
	IntervalAction *inA, *outA;
	[inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kOrientationUpOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
	inA = [Sequence actions:
		   [DelayTime actionWithDuration:duration/2],
		   [Show action],
		   [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:90 deltaAngleX:0],
		   [CallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [Sequence actions:
			[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:90 deltaAngleX:0],
			[Hide action],
			[DelayTime actionWithDuration:duration/2],							
			nil ];
	
	[inScene do: inA];
	[outScene do: outA];
	
}
@end

//
// FlipAngular Transition
//
@implementation FlipAngularTransition
-(void) onEnter
{
	[super onEnter];
	
	IntervalAction *inA, *outA;
	[inScene setVisible: NO];

	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kOrientationRightOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
	inA = [Sequence actions:
			   [DelayTime actionWithDuration:duration/2],
			   [Show action],
			   [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:-45 deltaAngleX:0],
			   [CallFunc actionWithTarget:self selector:@selector(finish)],
			   nil ];
	outA = [Sequence actions:
				[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:45 deltaAngleX:0],
				[Hide action],
				[DelayTime actionWithDuration:duration/2],							
				nil ];

	[inScene do: inA];
	[outScene do: outA];
}
@end

//
// ZoomFlipX Transition
//
@implementation ZoomFlipXTransition
-(void) onEnter
{
	[super onEnter];
	
	IntervalAction *inA, *outA;
	[inScene setVisible: NO];
	
	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;
	
	if( orientation == kOrientationRightOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
	inA = [Sequence actions:
		   [DelayTime actionWithDuration:duration/2],
		   [Spawn actions:
			[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:0 deltaAngleX:0],
			[ScaleTo actionWithDuration:duration/2 scale:1],
			[Show action],
			nil],
		   [CallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [Sequence actions:
			[Spawn actions:
			 [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:0 deltaAngleX:0],
			 [ScaleTo actionWithDuration:duration/2 scale:0.5],
			 nil],
			[Hide action],
			[DelayTime actionWithDuration:duration/2],							
			nil ];
	
	inScene.scale = 0.5f;
	[inScene do: inA];
	[outScene do: outA];
}
@end

//
// ZoomFlipY Transition
//
@implementation ZoomFlipYTransition
-(void) onEnter
{
	[super onEnter];
	
	IntervalAction *inA, *outA;
	[inScene setVisible: NO];
	
	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;

	if( orientation == kOrientationUpOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
	
	inA = [Sequence actions:
			   [DelayTime actionWithDuration:duration/2],
			   [Spawn actions:
				 [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:90 deltaAngleX:0],
				 [ScaleTo actionWithDuration:duration/2 scale:1],
				 [Show action],
				 nil],
			   [CallFunc actionWithTarget:self selector:@selector(finish)],
			   nil ];
	outA = [Sequence actions:
				[Spawn actions:
				 [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:90 deltaAngleX:0],
				 [ScaleTo actionWithDuration:duration/2 scale:0.5],
				 nil],							
				[Hide action],
				[DelayTime actionWithDuration:duration/2],							
				nil ];

	inScene.scale = 0.5;
	[inScene do: inA];
	[outScene do: outA];
}
@end

//
// ZoomFlipAngular Transition
//
@implementation ZoomFlipAngularTransition
-(void) onEnter
{
	[super onEnter];
	
	IntervalAction *inA, *outA;
	[inScene setVisible: NO];
	
	float inDeltaZ, inAngleZ;
	float outDeltaZ, outAngleZ;
	
	if( orientation == kOrientationRightOver ) {
		inDeltaZ = 90;
		inAngleZ = 270;
		outDeltaZ = 90;
		outAngleZ = 0;
	} else {
		inDeltaZ = -90;
		inAngleZ = 90;
		outDeltaZ = -90;
		outAngleZ = 0;
	}
		
	inA = [Sequence actions:
		   [DelayTime actionWithDuration:duration/2],
		   [Spawn actions:
			[OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:-45 deltaAngleX:0],
			[ScaleTo actionWithDuration:duration/2 scale:1],
			[Show action],
			nil],						   
		   [Show action],
		   [CallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [Sequence actions:
			[Spawn actions:
			 [OrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:45 deltaAngleX:0],
			 [ScaleTo actionWithDuration:duration/2 scale:0.5],
			 nil],							
			[Hide action],
			[DelayTime actionWithDuration:duration/2],							
			nil ];
	
	inScene.scale = 0.5;
	[inScene do: inA];
	[outScene do: outA];
}
@end


//
// Fade Transition
//
@implementation FadeTransition
-(void) onEnter
{
	[super onEnter];
	
	ColorLayer *l = [ColorLayer layerWithColor: 0x00000000];
	[inScene setVisible: NO];
	
	[self add: l z:2 name:@"fade"];
	
	
	CocosNode *f = [self get:@"fade"];

	IntervalAction *a = [Sequence actions:
							[FadeIn actionWithDuration:duration/2],
							[CallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
							[FadeOut actionWithDuration:duration/2],
							[CallFunc actionWithTarget:self selector:@selector(finish)],
						 nil ];
	[f do: a];
}

-(void) onExit
{
	[super onExit];
	[self removeByName: @"fade"];
}

-(void) hideOutShowIn
{
	[inScene setVisible:YES];
	[outScene setVisible:NO];
}
@end


