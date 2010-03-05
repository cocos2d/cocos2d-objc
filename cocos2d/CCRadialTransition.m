/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2010 Lam Pham
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCDirector.h"
#import "CCRadialTransition.h"
#import "CCRenderTexture.h"
#import "CCLayer.h"
#import "CCInstantAction.h"
#import "Support/CGPointExtension.h"

enum {
	kSceneRadial = 0xc001,
};

@implementation CCRadialCCWTransition
-(void) sceneOrder
{
	inSceneOnTop = NO;
}
-(CCProgressTimerType) radialType
{
	return kCCProgressTimerTypeRadialCCW;
}
-(void) onEnter
{
	[super onEnter];
	// create a transparent color layer
	// in which we are going to add our rendertextures
	CGSize size = [[CCDirector sharedDirector] winSize];
		
	// create the second render texture for outScene
	CCRenderTexture *outTexture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height];
	outTexture.sprite.anchorPoint= ccp(0.5f,0.5f);
	outTexture.position = ccp(size.width/2, size.height/2);
	outTexture.anchorPoint = ccp(0.5f,0.5f);
	
	// render outScene to its texturebuffer
	[outTexture clear:0 g:0 b:0 a:1];
	[outTexture begin];
	[outScene visit];
	[outTexture end];
	
	//	Since we've passed the outScene to the texture we don't need it.
	[self hideOutShowIn];
	
	//	We need the texture in RenderTexture.
	CCProgressTimer *outNode = [CCProgressTimer progressWithTexture:outTexture.sprite.texture];
	// but it's flipped upside down so we flip the sprite
	outNode.sprite.flipY = YES;
	//	Return the radial type that we want to use
	outNode.type = [self radialType];
	outNode.percentage = 100.f;
	outNode.position = ccp(size.width/2, size.height/2);
	outNode.anchorPoint = ccp(0.5f,0.5f);
			
	// create the blend action
	CCIntervalAction * layerAction = [CCSequence actions:
									  [CCProgressFromTo actionWithDuration:duration from:100.f to:0.f],
									  [CCCallFunc actionWithTarget:self selector:@selector(finish)],
									  nil ];	
	// run the blend action
	[outNode runAction: layerAction];
	
	// add the layer (which contains our two rendertextures) to the scene
	[self addChild: outNode z:2 tag:kSceneRadial];
}

// clean up on exit
-(void) onExit
{
	// remove our layer and release all containing objects 
	[self removeChildByTag:kSceneRadial cleanup:NO];
	[super onExit];	
}
@end

@implementation CCRadialCWTransition
-(CCProgressTimerType) radialType
{
	return kCCProgressTimerTypeRadialCW;
}
@end
