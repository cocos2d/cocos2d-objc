/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
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
#import "TiledGridAction.h"
#import "EaseAction.h"

enum {
	kSceneFade = 0xFADEFADE,
};

@interface TransitionScene (Private)
-(void) addScenes;
@end

@implementation TransitionScene
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s
{
	return [[[self alloc] initWithDuration:t scene:s] autorelease];
}

-(id) initWithDuration:(ccTime) t scene:(Scene*)s
{
	NSAssert( s != nil, @"Argument scene must be non-nil");
	
	if( ! (self=[super init]) )
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

	[self addScenes];
	return self;
}

-(void) addScenes
{
	// add both scenes
	[self add: inScene z:1];
	[self add: outScene z:0];
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
	
	[outScene setVisible:NO];
	[outScene setPosition:cpv(0,0)];
	[outScene setScale:1.0f];
	[outScene setRotation:0.0f];
	[outScene.camera restore];
	
//	[inScene stopAllActions];
//	[outScene stopAllActions];

	[self schedule:@selector(step:) interval:0];
}

-(void) hideOutShowIn
{
	[inScene setVisible:YES];
	[outScene setVisible:NO];
}


-(void) dealloc
{
	[super dealloc];
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
	if( !(self=[super initWithDuration:t scene:s]) )
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
		[Accelerate actionWithAction:a rate:0.5f],
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

	[inScene do: [Accelerate actionWithAction:in rate:0.5f]];
	[outScene do: [Sequence actions:
				   [Accelerate actionWithAction:out rate:0.5f],
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

	[inScene do: [Accelerate actionWithAction:scaleIn rate:0.5f]];
	[outScene do: [Sequence actions:
					[Accelerate actionWithAction:scaleOut rate:0.5f],
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
			 [ScaleTo actionWithDuration:duration/2 scale:0.5f],
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
				 [ScaleTo actionWithDuration:duration/2 scale:0.5f],
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
			 [ScaleTo actionWithDuration:duration/2 scale:0.5f],
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
// Fade Transition
//
@implementation FadeTransition
+(id) transitionWithDuration:(ccTime)d scene:(Scene*)s withColorRGB:(unsigned int)rgb
{
	return [[[self alloc] initWithDuration:d scene:s withColorRGB:rgb] autorelease];
}

-(id) initWithDuration:(ccTime)d scene:(Scene*)s withColorRGB:(unsigned int)rgb
{
	self = [super initWithDuration:d scene:s];
	if( self ) 
		RGBA = rgb << 8;
	
	return self;
}

-(id) initWithDuration:(ccTime)d scene:(Scene*)s
{
	return [self initWithDuration:d scene:s withColorRGB:0x00000000];
}

-(void) onEnter
{
	[super onEnter];
	
	ColorLayer *l = [ColorLayer layerWithColor:RGBA];
	[inScene setVisible: NO];
	
	[self add: l z:2 tag:kSceneFade];
	
	
	CocosNode *f = [self getByTag:kSceneFade];

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
	[self removeByTag:kSceneFade];
}
@end

//
// TurnOffTilesTransition
//
@implementation TurnOffTilesTransition

// override addScenes, and change the order
-(void) addScenes
{
	// add both scenes
	[self add: inScene z:0];
	[self add: outScene z:1];
}

-(void) onEnter
{
	[super onEnter];
	CGRect s = [[Director sharedDirector] winSize];
	float aspect = s.size.width / s.size.height;
	int x = 12 * aspect;
	int y = 12;
	
	id toff = [TurnOffTiles actionWithSize: cpv(x,y) duration:duration];
	[outScene do: [Sequence actions: toff,
				   [CallFunc actionWithTarget:self selector:@selector(finish)],
				   [StopGrid action],
				   nil]
	 ];

}
@end

#pragma mark Split Transitions

//
// SplitCols Transition
//
@implementation SplitColsTransition

-(void) onEnter
{
	[super onEnter];

	inScene.visible = NO;
	
	id split = [self action];
	id seq = [Sequence actions:
				split,
				[CallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
				[split reverse],
				nil
			  ];
	[self do: [Sequence actions:
			   [EaseCubicInOut actionWithAction:seq],
			   [CallFunc actionWithTarget:self selector:@selector(finish)],
			   [StopGrid action],
			   nil]
	 ];
}

-(IntervalAction*) action
{
	return [SplitCols actionWithCols:3 duration:duration/2.0f];
}
@end

//
// SplitRows Transition
//
@implementation SplitRowsTransition
-(IntervalAction*) action
{
	return [SplitRows actionWithRows:3 duration:duration/2.0f];
}
@end


#pragma mark Fade Grid Transitions

//
// FadeTR Transition
//
@implementation FadeTRTransition
// override addScenes, and change the order
-(void) addScenes
{
	// add both scenes
	[self add: inScene z:0];
	[self add: outScene z:1];
}

-(void) onEnter
{
	[super onEnter];
	
	CGRect s = [[Director sharedDirector] winSize];
	float aspect = s.size.width / s.size.height;
	int x = 12 * aspect;
	int y = 12;
	
	id action  = [self actionWithSize:cpv(x,y)];

	[outScene do: [Sequence actions:
					action,
				    [CallFunc actionWithTarget:self selector:@selector(finish)],
				    [StopGrid action],
				    nil]
	 ];
}

-(IntervalAction*) actionWithSize: (cpVect) v
{
	return [FadeOutTRTiles actionWithSize:v duration:duration];
}
@end

//
// FadeBL Transition
//
@implementation FadeBLTransition
-(IntervalAction*) actionWithSize: (cpVect) v
{
	return [FadeOutBLTiles actionWithSize:v duration:duration];
}
@end

//
// FadeUp Transition
//
@implementation FadeUpTransition
-(IntervalAction*) actionWithSize: (cpVect) v
{
	return [FadeOutUpTiles actionWithSize:v duration:duration];
}
@end

//
// FadeDown Transition
//
@implementation FadeDownTransition
-(IntervalAction*) actionWithSize: (cpVect) v
{
	return [FadeOutDownTiles actionWithSize:v duration:duration];
}
@end



