/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
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
#import "TouchDispatcher.h"
#import "Support/CGPointExtension.h"

enum {
	kSceneFade = 0xFADEFADE,
};

@interface TransitionScene (Private)
-(void) sceneOrder;
@end

@implementation TransitionScene
+(id) transitionWithDuration:(ccTime) t scene:(Scene*)s
{
	return [[[self alloc] initWithDuration:t scene:s] autorelease];
}

-(id) initWithDuration:(ccTime) t scene:(Scene*)s
{
	NSAssert( s != nil, @"Argument scene must be non-nil");
	
	if( (self=[super init]) ) {
	
		duration = t;
		
		// retain
		inScene = [s retain];
		outScene = [[Director sharedDirector] runningScene];
		[outScene retain];
		
		if( inScene == outScene ) {
			NSException* myException = [NSException
										exceptionWithName:@"TransitionWithInvalidScene"
										reason:@"Incoming scene must be different from the outgoing scene"
										userInfo:nil];
			@throw myException;		
		}
		
		// disable events while transitions
		[[TouchDispatcher sharedDispatcher] setDispatchEvents: NO];

		[self sceneOrder];
	}
	return self;
}
-(void) sceneOrder
{
	inSceneOnTop = YES;
}

-(void) draw
{
	if( inSceneOnTop ) {
		[outScene visit];
		[inScene visit];
	} else {
		[inScene visit];
		[outScene visit];
	}
}

-(void) finish
{
	/* clean up */	
	[inScene setVisible:YES];
	[inScene setPosition:ccp(0,0)];
	[inScene setScale:1.0f];
	[inScene setRotation:0.0f];
	[inScene.camera restore];
	
	[outScene setVisible:NO];
	[outScene setPosition:ccp(0,0)];
	[outScene setScale:1.0f];
	[outScene setRotation:0.0f];
	[outScene.camera restore];
	
	[self schedule:@selector(setNewScene:) interval:0];
}

-(void) setNewScene: (ccTime) dt
{	
	[self unschedule:_cmd];
	
	[[Director sharedDirector] replaceScene: inScene];
	
	// enable events while transitions
	[[TouchDispatcher sharedDispatcher] setDispatchEvents: YES];
	
	// issue #267
	[outScene setVisible:YES];	
}

-(void) hideOutShowIn
{
	[inScene setVisible:YES];
	[outScene setVisible:NO];
}

// custom onEnter
-(void) onEnter
{
	[super onEnter];
	[inScene onEnter];
	// outScene should not receive the onEnter callback
}

// custom onExit
-(void) onExit
{
	[super onExit];
	[outScene onExit];	

	// inScene should not receive the onExit callback
	// only the onEnterTransitionDidFinish
	[inScene onEnterTransitionDidFinish];
}

-(void) onEnterTransitionDidFinish
{
	[super onEnterTransitionDidFinish];
}

-(void) dealloc
{
	[inScene release];
	[outScene release];
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
	if( (self=[super initWithDuration:t scene:s]) )
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
	
	[inScene setScale:0.001f];
	[outScene setScale:1.0f];
	
	[inScene setAnchorPoint:ccp(0.5f, 0.5f)];
	[outScene setAnchorPoint:ccp(0.5f, 0.5f)];
	
	IntervalAction *rotozoom = [Sequence actions: [Spawn actions:
								   [ScaleBy actionWithDuration:duration/2 scale:0.001f],
								   [RotateBy actionWithDuration:duration/2 angle:360 *2],
								   nil],
								[DelayTime actionWithDuration:duration/2],
							nil];
	
	
	[outScene runAction: rotozoom];
	[inScene runAction: [Sequence actions:
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
	CGSize s = [[Director sharedDirector] winSize];
	
	[inScene setScale:0.5f];
	[inScene setPosition:ccp( s.width,0 )];

	[inScene setAnchorPoint:ccp(0.5f, 0.5f)];
	[outScene setAnchorPoint:ccp(0.5f, 0.5f)];

	IntervalAction *jump = [JumpBy actionWithDuration:duration/4 position:ccp(-s.width,0) height:s.width/4 jumps:2];
	IntervalAction *scaleIn = [ScaleTo actionWithDuration:duration/4 scale:1.0f];
	IntervalAction *scaleOut = [ScaleTo actionWithDuration:duration/4 scale:0.5f];
	
	IntervalAction *jumpZoomOut = [Sequence actions: scaleOut, jump, nil];
	IntervalAction *jumpZoomIn = [Sequence actions: jump, scaleIn, nil];
	
	IntervalAction *delay = [DelayTime actionWithDuration:duration/2];
	
	[outScene runAction: jumpZoomOut];
	[inScene runAction: [Sequence actions: delay,
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

	[inScene runAction: [Sequence actions:
		[EaseOut actionWithAction:a rate:2.0f],
		[CallFunc actionWithTarget:self selector:@selector(finish)],
		nil] ];
	 		
}
-(IntervalAction*) action
{
	return [MoveTo actionWithDuration:duration position:ccp(0,0)];
}

-(void) initScenes
{
	CGSize s = [[Director sharedDirector] winSize];
	[inScene setPosition: ccp( -s.width,0) ];
}
@end

//
// MoveInR
//
@implementation MoveInRTransition
-(void) initScenes
{
	CGSize s = [[Director sharedDirector] winSize];
	[inScene setPosition: ccp( s.width,0) ];
}
@end

//
// MoveInT
//
@implementation MoveInTTransition
-(void) initScenes
{
	CGSize s = [[Director sharedDirector] winSize];
	[inScene setPosition: ccp( 0, s.height) ];
}
@end

//
// MoveInB
//
@implementation MoveInBTransition
-(void) initScenes
{
	CGSize s = [[Director sharedDirector] winSize];
	[inScene setPosition: ccp( 0, -s.height) ];
}
@end

//
// SlideInL
//

// The adjust factor is needed to prevent issue #442
// One solution is to use DONT_RENDER_IN_SUBPIXELS images, but NO
// The other issue is that in some transitions (and I don't know why)
// the order should be reversed (In in top of Out or vice-versa).
#define ADJUST_FACTOR 0.5f
@implementation SlideInLTransition
-(void) onEnter
{
	[super onEnter];

	[self initScenes];
	
	IntervalAction *in = [self action];
	IntervalAction *out = [self action];

	id inAction = [EaseOut actionWithAction:in rate:2.0f];
	id outAction = [Sequence actions:
					[EaseOut actionWithAction:out rate:2.0f],
					[CallFunc actionWithTarget:self selector:@selector(finish)],
					nil];
	
	[inScene runAction: inAction];
	[outScene runAction: outAction];
}
-(void) sceneOrder
{
	inSceneOnTop = NO;
}
-(void) initScenes
{
	CGSize s = [[Director sharedDirector] winSize];
	[inScene setPosition: ccp( -(s.width-ADJUST_FACTOR),0) ];
}
-(IntervalAction*) action
{
	CGSize s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration position:ccp(s.width-ADJUST_FACTOR,0)];
}

@end

//
// SlideInR
//
@implementation SlideInRTransition
-(void) sceneOrder
{
	inSceneOnTop = YES;
}
-(void) initScenes
{
	CGSize s = [[Director sharedDirector] winSize];
	[inScene setPosition: ccp( s.width-ADJUST_FACTOR,0) ];
}

-(IntervalAction*) action
{
	CGSize s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration position:ccp(-(s.width-ADJUST_FACTOR),0)];
}

@end

//
// SlideInT
//
@implementation SlideInTTransition
-(void) sceneOrder
{
	inSceneOnTop = NO;
}
-(void) initScenes
{
	CGSize s = [[Director sharedDirector] winSize];
	[inScene setPosition: ccp(0,s.height-ADJUST_FACTOR) ];
}

-(IntervalAction*) action
{
	CGSize s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration position:ccp(0,-(s.height-ADJUST_FACTOR))];
}

@end

//
// SlideInB
//
@implementation SlideInBTransition
-(void) sceneOrder
{
	inSceneOnTop = YES;
}

-(void) initScenes
{
	CGSize s = [[Director sharedDirector] winSize];
	[inScene setPosition: ccp(0,-(s.height-ADJUST_FACTOR)) ];
}

-(IntervalAction*) action
{
	CGSize s = [[Director sharedDirector] winSize];
	return [MoveBy actionWithDuration:duration position:ccp(0,s.height-ADJUST_FACTOR)];
}
@end

//
// ShrinkGrow Transition
//
@implementation ShrinkGrowTransition
-(void) onEnter
{
	[super onEnter];
	
	[inScene setScale:0.001f];
	[outScene setScale:1.0f];

	[inScene setAnchorPoint:ccp(2/3.0f,0.5f)];
	[outScene setAnchorPoint:ccp(1/3.0f,0.5f)];	
	
	IntervalAction *scaleOut = [ScaleTo actionWithDuration:duration scale:0.01f];
	IntervalAction *scaleIn = [ScaleTo actionWithDuration:duration scale:1.0f];

	[inScene runAction: [EaseOut actionWithAction:scaleIn rate:2.0f]];
	[outScene runAction: [Sequence actions:
					[EaseOut actionWithAction:scaleOut rate:2.0f],
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
	
	[inScene runAction: inA];
	[outScene runAction: outA];
	
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
	
	[inScene runAction: inA];
	[outScene runAction: outA];
	
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

	[inScene runAction: inA];
	[outScene runAction: outA];
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
	[inScene runAction: inA];
	[outScene runAction: outA];
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
	[inScene runAction: inA];
	[outScene runAction: outA];
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
	[inScene runAction: inA];
	[outScene runAction: outA];
}
@end


//
// Fade Transition
//
@implementation FadeTransition
+(id) transitionWithDuration:(ccTime)d scene:(Scene*)s withColor:(ccColor3B)color
{
	return [[[self alloc] initWithDuration:d scene:s withColor:color] autorelease];
}

-(id) initWithDuration:(ccTime)d scene:(Scene*)s withColor:(ccColor3B)aColor
{
	if( (self=[super initWithDuration:d scene:s]) ) {
		color.r = aColor.r;
		color.g = aColor.g;
		color.b = aColor.b;
	}
	
	return self;
}

-(id) initWithDuration:(ccTime)d scene:(Scene*)s
{
	return [self initWithDuration:d scene:s withColor:ccBLACK];
}

-(void) onEnter
{
	[super onEnter];
	
	ColorLayer *l = [ColorLayer layerWithColor:color];
	[inScene setVisible: NO];
	
	[self addChild: l z:2 tag:kSceneFade];
	
	
	CocosNode *f = [self getChildByTag:kSceneFade];

	IntervalAction *a = [Sequence actions:
							[FadeIn actionWithDuration:duration/2],
							[CallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
							[FadeOut actionWithDuration:duration/2],
							[CallFunc actionWithTarget:self selector:@selector(finish)],
						 nil ];
	[f runAction: a];
}

-(void) onExit
{
	[super onExit];
	[self removeChildByTag:kSceneFade cleanup:NO];
}
@end

//
// TurnOffTilesTransition
//
@implementation TurnOffTilesTransition

// override addScenes, and change the order
-(void) sceneOrder
{
	inSceneOnTop = NO;
}

-(void) onEnter
{
	[super onEnter];
	CGSize s = [[Director sharedDirector] winSize];
	float aspect = s.width / s.height;
	int x = 12 * aspect;
	int y = 12;
	
	id toff = [TurnOffTiles actionWithSize: ccg(x,y) duration:duration];
	[outScene runAction: [Sequence actions: toff,
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
	[self runAction: [Sequence actions:
			   [EaseInOut actionWithAction:seq rate:3.0f],
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
-(void) sceneOrder
{
	inSceneOnTop = NO;
}

-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[Director sharedDirector] winSize];
	float aspect = s.width / s.height;
	int x = 12 * aspect;
	int y = 12;
	
	id action  = [self actionWithSize:ccg(x,y)];

	[outScene runAction: [Sequence actions:
					action,
				    [CallFunc actionWithTarget:self selector:@selector(finish)],
				    [StopGrid action],
				    nil]
	 ];
}

-(IntervalAction*) actionWithSize: (ccGridSize) v
{
	return [FadeOutTRTiles actionWithSize:v duration:duration];
}
@end

//
// FadeBL Transition
//
@implementation FadeBLTransition
-(IntervalAction*) actionWithSize: (ccGridSize) v
{
	return [FadeOutBLTiles actionWithSize:v duration:duration];
}
@end

//
// FadeUp Transition
//
@implementation FadeUpTransition
-(IntervalAction*) actionWithSize: (ccGridSize) v
{
	return [FadeOutUpTiles actionWithSize:v duration:duration];
}
@end

//
// FadeDown Transition
//
@implementation FadeDownTransition
-(IntervalAction*) actionWithSize: (ccGridSize) v
{
	return [FadeOutDownTiles actionWithSize:v duration:duration];
}
@end



