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


#import "CCTransition.h"
#import "CCNode.h"
#import "CCDirector.h"
#import "CCIntervalAction.h"
#import "CCInstantAction.h"
#import "CCCameraAction.h"
#import "CCLayer.h"
#import "CCCamera.h"
#import "CCTiledGridAction.h"
#import "CCEaseAction.h"
#import "CCTouchDispatcher.h"
#import "CCRenderTexture.h"
#import "Support/CGPointExtension.h"

enum {
	kSceneFade = 0xFADEFADE,
};

@interface CCTransitionScene (Private)
-(void) sceneOrder;
- (void)setNewScene:(ccTime)dt;
@end

@implementation CCTransitionScene
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s
{
	return [[[self alloc] initWithDuration:t scene:s] autorelease];
}

-(id) initWithDuration:(ccTime) t scene:(CCScene*)s
{
	NSAssert( s != nil, @"Argument scene must be non-nil");
	
	if( (self=[super init]) ) {
	
		duration = t;
		
		// retain
		inScene = [s retain];
		outScene = [[CCDirector sharedDirector] runningScene];
		[outScene retain];
		
		NSAssert( inScene != outScene, @"Incoming scene must be different from the outgoing scene" );
		
		// disable events while transitions
		[[CCTouchDispatcher sharedDispatcher] setDispatchEvents: NO];

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
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Before replacing, save the "send cleanup to scene"
	sendCleanupToScene = [director sendCleanupToScene];
	
	[director replaceScene: inScene];
	
	// enable events while transitions
	[[CCTouchDispatcher sharedDispatcher] setDispatchEvents: YES];
	
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

// custom cleanup
-(void) cleanup
{
	[super cleanup];
	
	if( sendCleanupToScene )
	   [outScene cleanup];
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
@implementation CCOrientedTransitionScene
+(id) transitionWithDuration:(ccTime) t scene:(CCScene*)s orientation:(tOrientation)o
{
	return [[[self alloc] initWithDuration:t scene:s orientation:o] autorelease];
}

-(id) initWithDuration:(ccTime) t scene:(CCScene*)s orientation:(tOrientation)o
{
	if( (self=[super initWithDuration:t scene:s]) )
		orientation = o;
	return self;
}
@end


//
// RotoZoom
//
@implementation CCRotoZoomTransition
-(void) onEnter
{
	[super onEnter];
	
	[inScene setScale:0.001f];
	[outScene setScale:1.0f];
	
	[inScene setAnchorPoint:ccp(0.5f, 0.5f)];
	[outScene setAnchorPoint:ccp(0.5f, 0.5f)];
	
	CCIntervalAction *rotozoom = [CCSequence actions: [CCSpawn actions:
								   [CCScaleBy actionWithDuration:duration/2 scale:0.001f],
								   [CCRotateBy actionWithDuration:duration/2 angle:360 *2],
								   nil],
								[CCDelayTime actionWithDuration:duration/2],
							nil];
	
	
	[outScene runAction: rotozoom];
	[inScene runAction: [CCSequence actions:
					[rotozoom reverse],
					[CCCallFunc actionWithTarget:self selector:@selector(finish)],
				  nil]];
}
@end

//
// JumpZoom
//
@implementation CCJumpZoomTransition
-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	[inScene setScale:0.5f];
	[inScene setPosition:ccp( s.width,0 )];

	[inScene setAnchorPoint:ccp(0.5f, 0.5f)];
	[outScene setAnchorPoint:ccp(0.5f, 0.5f)];

	CCIntervalAction *jump = [CCJumpBy actionWithDuration:duration/4 position:ccp(-s.width,0) height:s.width/4 jumps:2];
	CCIntervalAction *scaleIn = [CCScaleTo actionWithDuration:duration/4 scale:1.0f];
	CCIntervalAction *scaleOut = [CCScaleTo actionWithDuration:duration/4 scale:0.5f];
	
	CCIntervalAction *jumpZoomOut = [CCSequence actions: scaleOut, jump, nil];
	CCIntervalAction *jumpZoomIn = [CCSequence actions: jump, scaleIn, nil];
	
	CCIntervalAction *delay = [CCDelayTime actionWithDuration:duration/2];
	
	[outScene runAction: jumpZoomOut];
	[inScene runAction: [CCSequence actions: delay,
								jumpZoomIn,
								[CCCallFunc actionWithTarget:self selector:@selector(finish)],
								nil] ];
}
@end

//
// MoveInL
//
@implementation CCMoveInLTransition
-(void) onEnter
{
	[super onEnter];
	
	[self initScenes];
	
	CCIntervalAction *a = [self action];

	[inScene runAction: [CCSequence actions:
						 [self easeActionWithAction:a],
						 [CCCallFunc actionWithTarget:self selector:@selector(finish)],
						 nil]
	];
	 		
}
-(CCIntervalAction*) action
{
	return [CCMoveTo actionWithDuration:duration position:ccp(0,0)];
}

-(CCIntervalAction*) easeActionWithAction:(CCIntervalAction*)action
{
	return [CCEaseOut actionWithAction:action rate:2.0f];
//	return [EaseElasticOut actionWithAction:action period:0.4f];
}

-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[inScene setPosition: ccp( -s.width,0) ];
}
@end

//
// MoveInR
//
@implementation CCMoveInRTransition
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[inScene setPosition: ccp( s.width,0) ];
}
@end

//
// MoveInT
//
@implementation CCMoveInTTransition
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[inScene setPosition: ccp( 0, s.height) ];
}
@end

//
// MoveInB
//
@implementation CCMoveInBTransition
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
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
@implementation CCSlideInLTransition
-(void) onEnter
{
	[super onEnter];

	[self initScenes];
	
	CCIntervalAction *in = [self action];
	CCIntervalAction *out = [self action];

	id inAction = [self easeActionWithAction:in];
	id outAction = [CCSequence actions:
					[self easeActionWithAction:out],
					[CCCallFunc actionWithTarget:self selector:@selector(finish)],
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
	CGSize s = [[CCDirector sharedDirector] winSize];
	[inScene setPosition: ccp( -(s.width-ADJUST_FACTOR),0) ];
}
-(CCIntervalAction*) action
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [CCMoveBy actionWithDuration:duration position:ccp(s.width-ADJUST_FACTOR,0)];
}

-(CCIntervalAction*) easeActionWithAction:(CCIntervalAction*)action
{
	return [CCEaseOut actionWithAction:action rate:2.0f];
//	return [EaseElasticOut actionWithAction:action period:0.4f];
}

@end

//
// SlideInR
//
@implementation CCSlideInRTransition
-(void) sceneOrder
{
	inSceneOnTop = YES;
}
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[inScene setPosition: ccp( s.width-ADJUST_FACTOR,0) ];
}

-(CCIntervalAction*) action
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [CCMoveBy actionWithDuration:duration position:ccp(-(s.width-ADJUST_FACTOR),0)];
}

@end

//
// SlideInT
//
@implementation CCSlideInTTransition
-(void) sceneOrder
{
	inSceneOnTop = NO;
}
-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[inScene setPosition: ccp(0,s.height-ADJUST_FACTOR) ];
}

-(CCIntervalAction*) action
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [CCMoveBy actionWithDuration:duration position:ccp(0,-(s.height-ADJUST_FACTOR))];
}

@end

//
// SlideInB
//
@implementation CCSlideInBTransition
-(void) sceneOrder
{
	inSceneOnTop = YES;
}

-(void) initScenes
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	[inScene setPosition: ccp(0,-(s.height-ADJUST_FACTOR)) ];
}

-(CCIntervalAction*) action
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	return [CCMoveBy actionWithDuration:duration position:ccp(0,s.height-ADJUST_FACTOR)];
}
@end

//
// ShrinkGrow Transition
//
@implementation CCShrinkGrowTransition
-(void) onEnter
{
	[super onEnter];
	
	[inScene setScale:0.001f];
	[outScene setScale:1.0f];

	[inScene setAnchorPoint:ccp(2/3.0f,0.5f)];
	[outScene setAnchorPoint:ccp(1/3.0f,0.5f)];	
	
	CCIntervalAction *scaleOut = [CCScaleTo actionWithDuration:duration scale:0.01f];
	CCIntervalAction *scaleIn = [CCScaleTo actionWithDuration:duration scale:1.0f];

	[inScene runAction: [self easeActionWithAction:scaleIn]];
	[outScene runAction: [CCSequence actions:
					[self easeActionWithAction:scaleOut],
					[CCCallFunc actionWithTarget:self selector:@selector(finish)],
					nil] ];
}
-(CCIntervalAction*) easeActionWithAction:(CCIntervalAction*)action
{
	return [CCEaseOut actionWithAction:action rate:2.0f];
//	return [EaseElasticOut actionWithAction:action period:0.3f];
}
@end

//
// FlipX Transition
//
@implementation CCFlipXTransition
-(void) onEnter
{
	[super onEnter];
	
	CCIntervalAction *inA, *outA;
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
		
	inA = [CCSequence actions:
		   [CCDelayTime actionWithDuration:duration/2],
		   [CCShow action],
		   [CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:0 deltaAngleX:0],
		   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [CCSequence actions:
			[CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:0 deltaAngleX:0],
			[CCHide action],
			[CCDelayTime actionWithDuration:duration/2],							
			nil ];
	
	[inScene runAction: inA];
	[outScene runAction: outA];
	
}
@end

//
// FlipY Transition
//
@implementation CCFlipYTransition
-(void) onEnter
{
	[super onEnter];
	
	CCIntervalAction *inA, *outA;
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
	inA = [CCSequence actions:
		   [CCDelayTime actionWithDuration:duration/2],
		   [CCShow action],
		   [CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:90 deltaAngleX:0],
		   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [CCSequence actions:
			[CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:90 deltaAngleX:0],
			[CCHide action],
			[CCDelayTime actionWithDuration:duration/2],							
			nil ];
	
	[inScene runAction: inA];
	[outScene runAction: outA];
	
}
@end

//
// FlipAngular Transition
//
@implementation CCFlipAngularTransition
-(void) onEnter
{
	[super onEnter];
	
	CCIntervalAction *inA, *outA;
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
	inA = [CCSequence actions:
			   [CCDelayTime actionWithDuration:duration/2],
			   [CCShow action],
			   [CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:-45 deltaAngleX:0],
			   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
			   nil ];
	outA = [CCSequence actions:
				[CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:45 deltaAngleX:0],
				[CCHide action],
				[CCDelayTime actionWithDuration:duration/2],							
				nil ];

	[inScene runAction: inA];
	[outScene runAction: outA];
}
@end

//
// ZoomFlipX Transition
//
@implementation CCZoomFlipXTransition
-(void) onEnter
{
	[super onEnter];
	
	CCIntervalAction *inA, *outA;
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
	inA = [CCSequence actions:
		   [CCDelayTime actionWithDuration:duration/2],
		   [CCSpawn actions:
			[CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:0 deltaAngleX:0],
			[CCScaleTo actionWithDuration:duration/2 scale:1],
			[CCShow action],
			nil],
		   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [CCSequence actions:
			[CCSpawn actions:
			 [CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:0 deltaAngleX:0],
			 [CCScaleTo actionWithDuration:duration/2 scale:0.5f],
			 nil],
			[CCHide action],
			[CCDelayTime actionWithDuration:duration/2],							
			nil ];
	
	inScene.scale = 0.5f;
	[inScene runAction: inA];
	[outScene runAction: outA];
}
@end

//
// ZoomFlipY Transition
//
@implementation CCZoomFlipYTransition
-(void) onEnter
{
	[super onEnter];
	
	CCIntervalAction *inA, *outA;
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
	
	inA = [CCSequence actions:
			   [CCDelayTime actionWithDuration:duration/2],
			   [CCSpawn actions:
				 [CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:90 deltaAngleX:0],
				 [CCScaleTo actionWithDuration:duration/2 scale:1],
				 [CCShow action],
				 nil],
			   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
			   nil ];
	outA = [CCSequence actions:
				[CCSpawn actions:
				 [CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:90 deltaAngleX:0],
				 [CCScaleTo actionWithDuration:duration/2 scale:0.5f],
				 nil],							
				[CCHide action],
				[CCDelayTime actionWithDuration:duration/2],							
				nil ];

	inScene.scale = 0.5f;
	[inScene runAction: inA];
	[outScene runAction: outA];
}
@end

//
// ZoomFlipAngular Transition
//
@implementation CCZoomFlipAngularTransition
-(void) onEnter
{
	[super onEnter];
	
	CCIntervalAction *inA, *outA;
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
		
	inA = [CCSequence actions:
		   [CCDelayTime actionWithDuration:duration/2],
		   [CCSpawn actions:
			[CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:inAngleZ deltaAngleZ:inDeltaZ angleX:-45 deltaAngleX:0],
			[CCScaleTo actionWithDuration:duration/2 scale:1],
			[CCShow action],
			nil],						   
		   [CCShow action],
		   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
		   nil ];
	outA = [CCSequence actions:
			[CCSpawn actions:
			 [CCOrbitCamera actionWithDuration: duration/2 radius: 1 deltaRadius:0 angleZ:outAngleZ deltaAngleZ:outDeltaZ angleX:45 deltaAngleX:0],
			 [CCScaleTo actionWithDuration:duration/2 scale:0.5f],
			 nil],							
			[CCHide action],
			[CCDelayTime actionWithDuration:duration/2],							
			nil ];
	
	inScene.scale = 0.5f;
	[inScene runAction: inA];
	[outScene runAction: outA];
}
@end


//
// Fade Transition
//
@implementation CCFadeTransition
+(id) transitionWithDuration:(ccTime)d scene:(CCScene*)s withColor:(ccColor3B)color
{
	return [[[self alloc] initWithDuration:d scene:s withColor:color] autorelease];
}

-(id) initWithDuration:(ccTime)d scene:(CCScene*)s withColor:(ccColor3B)aColor
{
	if( (self=[super initWithDuration:d scene:s]) ) {
		color.r = aColor.r;
		color.g = aColor.g;
		color.b = aColor.b;
	}
	
	return self;
}

-(id) initWithDuration:(ccTime)d scene:(CCScene*)s
{
	return [self initWithDuration:d scene:s withColor:ccBLACK];
}

-(void) onEnter
{
	[super onEnter];
	
	CCColorLayer *l = [CCColorLayer layerWithColor:color];
	[inScene setVisible: NO];
	
	[self addChild: l z:2 tag:kSceneFade];
	
	
	CCNode *f = [self getChildByTag:kSceneFade];
	
	CCIntervalAction *a = [CCSequence actions:
						   [CCFadeIn actionWithDuration:duration/2],
						   [CCCallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
						   [CCFadeOut actionWithDuration:duration/2],
						   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
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
// Cross Fade Transition
//
@implementation CCCrossFadeTransition

-(void) draw
{
	// override draw since both scenes (textures) are rendered in 1 scene
}

-(void) onEnter
{
	[super onEnter];
	
	// create a transparent color layer
	// in which we are going to add our rendertextures
	ccColor4B  color = {0,0,0,0};
	CGSize size = [[CCDirector sharedDirector] winSize];
	CCColorLayer * layer = [CCColorLayer layerWithColor:color];
	
	// create the first render texture for inScene
	CCRenderTexture *inTexture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height];
	inTexture.sprite.anchorPoint= ccp(0.5f,0.5f);
	inTexture.position = ccp(size.width/2, size.height/2);
	inTexture.anchorPoint = ccp(0.5f,0.5f);
	
	// render inScene to its texturebuffer
	[inTexture begin];
	[inScene visit];
	[inTexture end];
	
	// create the second render texture for outScene
	CCRenderTexture *outTexture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height];
	outTexture.sprite.anchorPoint= ccp(0.5f,0.5f);
	outTexture.position = ccp(size.width/2, size.height/2);
	outTexture.anchorPoint = ccp(0.5f,0.5f);
	
	// render outScene to its texturebuffer
	[outTexture begin];
	[outScene visit];
	[outTexture end];
	
	// create blend functions
	
	ccBlendFunc blend1 = {GL_ONE, GL_ONE}; // inScene will lay on background and will not be used with alpha
	ccBlendFunc blend2 = {GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA}; // we are going to blend outScene via alpha 
	
	// set blendfunctions
	[inTexture.sprite setBlendFunc:blend1];
	[outTexture.sprite setBlendFunc:blend2];	
	
	// add render textures to the layer
	[layer addChild:inTexture];
	[layer addChild:outTexture];
	
	// initial opacity:
	[inTexture.sprite setOpacity:255];
	[outTexture.sprite setOpacity:255];
	
	// create the blend action
	CCIntervalAction * layerAction = [CCSequence actions:
									  [CCFadeTo actionWithDuration:duration opacity:0],
									  [CCCallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
									  [CCCallFunc actionWithTarget:self selector:@selector(finish)],
									  nil ];
	
	
	// run the blend action
	[outTexture.sprite runAction: layerAction];
	
	// add the layer (which contains our two rendertextures) to the scene
	[self addChild: layer z:2 tag:kSceneFade];
}

// clean up on exit
-(void) onExit
{
	// remove our layer and release all containing objects 
	[self removeChildByTag:kSceneFade cleanup:NO];
	
	[super onExit];	
}
@end

//
// TurnOffTilesTransition
//
@implementation CCTurnOffTilesTransition

// override addScenes, and change the order
-(void) sceneOrder
{
	inSceneOnTop = NO;
}

-(void) onEnter
{
	[super onEnter];
	CGSize s = [[CCDirector sharedDirector] winSize];
	float aspect = s.width / s.height;
	int x = 12 * aspect;
	int y = 12;
	
	id toff = [CCTurnOffTiles actionWithSize: ccg(x,y) duration:duration];
	id action = [self easeActionWithAction:toff];
	[outScene runAction: [CCSequence actions: action,
				   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
				   [CCStopGrid action],
				   nil]
	 ];

}
-(CCIntervalAction*) easeActionWithAction:(CCIntervalAction*)action
{
	return action;
//	return [EaseIn actionWithAction:action rate:2.0f];
}
@end

#pragma mark Split Transitions

//
// SplitCols Transition
//
@implementation CCSplitColsTransition

-(void) onEnter
{
	[super onEnter];

	inScene.visible = NO;
	
	id split = [self action];
	id seq = [CCSequence actions:
				split,
				[CCCallFunc actionWithTarget:self selector:@selector(hideOutShowIn)],
				[split reverse],
				nil
			  ];
	[self runAction: [CCSequence actions:
			   [self easeActionWithAction:seq],
			   [CCCallFunc actionWithTarget:self selector:@selector(finish)],
			   [CCStopGrid action],
			   nil]
	 ];
}

-(CCIntervalAction*) action
{
	return [CCSplitCols actionWithCols:3 duration:duration/2.0f];
}

-(CCIntervalAction*) easeActionWithAction:(CCIntervalAction*)action
{
	return [CCEaseInOut actionWithAction:action rate:3.0f];
}
@end

//
// SplitRows Transition
//
@implementation CCSplitRowsTransition
-(CCIntervalAction*) action
{
	return [CCSplitRows actionWithRows:3 duration:duration/2.0f];
}
@end


#pragma mark Fade Grid Transitions

//
// FadeTR Transition
//
@implementation CCFadeTRTransition
-(void) sceneOrder
{
	inSceneOnTop = NO;
}

-(void) onEnter
{
	[super onEnter];
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	float aspect = s.width / s.height;
	int x = 12 * aspect;
	int y = 12;
	
	id action  = [self actionWithSize:ccg(x,y)];

	[outScene runAction: [CCSequence actions:
					[self easeActionWithAction:action],
				    [CCCallFunc actionWithTarget:self selector:@selector(finish)],
				    [CCStopGrid action],
				    nil]
	 ];
}

-(CCIntervalAction*) actionWithSize: (ccGridSize) v
{
	return [CCFadeOutTRTiles actionWithSize:v duration:duration];
}

-(CCIntervalAction*) easeActionWithAction:(CCIntervalAction*)action
{
	return action;
//	return [EaseIn actionWithAction:action rate:2.0f];
}
@end

//
// FadeBL Transition
//
@implementation CCFadeBLTransition
-(CCIntervalAction*) actionWithSize: (ccGridSize) v
{
	return [CCFadeOutBLTiles actionWithSize:v duration:duration];
}
@end

//
// FadeUp Transition
//
@implementation CCFadeUpTransition
-(CCIntervalAction*) actionWithSize: (ccGridSize) v
{
	return [CCFadeOutUpTiles actionWithSize:v duration:duration];
}
@end

//
// FadeDown Transition
//
@implementation CCFadeDownTransition
-(CCIntervalAction*) actionWithSize: (ccGridSize) v
{
	return [CCFadeOutDownTiles actionWithSize:v duration:duration];
}
@end



