/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Lam Pham
 *
 * Copyright (c) 2012 Ricardo Quesada
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "CCTransitionProgress.h"
#import "CCDirector.h"
#import "CCRenderTexture.h"
#import "CCLayer.h"
#import "CCActionInstant.h"
#import "CCProgressTimer.h"
#import "CCActionProgressTimer.h"
#import "Support/CGPointExtension.h"

enum {
	kCCSceneRadial = 0xc001,
};

#pragma mark - CCTransitionProgress

@interface CCTransitionProgress()
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture;
-(void) setupTransition;
@end

@implementation CCTransitionProgress
-(void) onEnter
{
	[super onEnter];

	[self setupTransition];
	
	// create a transparent color layer
	// in which we are going to add our rendertextures
	CGSize size = [[CCDirector sharedDirector] winSize];

	// create the second render texture for outScene
	CCRenderTexture *texture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height];
	texture.sprite.anchorPoint= ccp(0.5f,0.5f);
	texture.position = ccp(size.width/2, size.height/2);
	texture.anchorPoint = ccp(0.5f,0.5f);

	// render outScene to its texturebuffer
	[texture clear:0 g:0 b:0 a:1];
	[texture begin];
	[sceneToBeModified_ visit];
	[texture end];


	//	Since we've passed the outScene to the texture we don't need it.
	if( sceneToBeModified_ == outScene_ )
		[self hideOutShowIn];

	//	We need the texture in RenderTexture.
	CCProgressTimer *node = [self progressTimerNodeWithRenderTexture:texture];

	// create the blend action
	CCActionInterval * layerAction = [CCSequence actions:
									  [CCProgressFromTo actionWithDuration:duration_ from:from_ to:to_],
									  [CCCallFunc actionWithTarget:self selector:@selector(finish)],
									  nil ];
	// run the blend action
	[node runAction: layerAction];

	// add the layer (which contains our two rendertextures) to the scene
	[self addChild: node z:2 tag:kCCSceneRadial];
}

// clean up on exit
-(void) onExit
{
	// remove our layer and release all containing objects
	[self removeChildByTag:kCCSceneRadial cleanup:NO];
	[super onExit];
}

-(void) sceneOrder
{
	inSceneOnTop_ = NO;
}

-(void) setupTransition
{
	sceneToBeModified_ = outScene_;
	from_ = 100;
	to_ = 0;
}

-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture
{
	NSAssert(NO, @"override me - abstract class");
	
	return nil;
}
@end

#pragma mark - CCTransitionProgressRadialCCW

@implementation CCTransitionProgressRadialCCW
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture
{
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCProgressTimer *node = [CCProgressTimer progressWithSprite:texture.sprite];

	// but it is flipped upside down so we flip the sprite
	node.sprite.flipY = YES;
	node.type = kCCProgressTimerTypeRadial;

	//	Return the radial type that we want to use
	node.reverseDirection = NO;
	node.percentage = 100;
	node.position = ccp(size.width/2, size.height/2);
	node.anchorPoint = ccp(0.5f,0.5f);
	
	return node;
}
@end

#pragma mark - CCTransitionProgressRadialCW

@implementation CCTransitionProgressRadialCW
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	CCProgressTimer *node = [CCProgressTimer progressWithSprite:texture.sprite];
	
	// but it is flipped upside down so we flip the sprite
	node.sprite.flipY = YES;
	node.type = kCCProgressTimerTypeRadial;
	
	//	Return the radial type that we want to use
	node.reverseDirection = YES;
	node.percentage = 100;
	node.position = ccp(size.width/2, size.height/2);
	node.anchorPoint = ccp(0.5f,0.5f);
	
	return node;
}
@end

#pragma mark - CCTransitionProgressHorizontal

@implementation CCTransitionProgressHorizontal
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture
{	
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCProgressTimer *node = [CCProgressTimer progressWithSprite:texture.sprite];
	
	// but it is flipped upside down so we flip the sprite
	node.sprite.flipY = YES;
	node.type = kCCProgressTimerTypeBar;
	
	node.midpoint = ccp(1, 0);
	node.barChangeRate = ccp(1,0);
	
	node.percentage = 100;
	node.position = ccp(size.width/2, size.height/2);
	node.anchorPoint = ccp(0.5f,0.5f);

	return node;
}
@end

#pragma mark - CCTransitionProgressVertical

@implementation CCTransitionProgressVertical
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture
{	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	CCProgressTimer *node = [CCProgressTimer progressWithSprite:texture.sprite];
	
	// but it is flipped upside down so we flip the sprite
	node.sprite.flipY = YES;
	node.type = kCCProgressTimerTypeBar;
	
	node.midpoint = ccp(0, 0);
	node.barChangeRate = ccp(0,1);
	
	node.percentage = 100;
	node.position = ccp(size.width/2, size.height/2);
	node.anchorPoint = ccp(0.5f,0.5f);
	
	return node;
}
@end

#pragma mark - CCTransitionProgressInOut

@implementation CCTransitionProgressInOut

-(void) sceneOrder
{
	inSceneOnTop_ = NO;
}

-(void) setupTransition
{
	sceneToBeModified_ = inScene_;
	from_ = 0;
	to_ = 100;	
}

-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture
{	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	CCProgressTimer *node = [CCProgressTimer progressWithSprite:texture.sprite];
	
	// but it is flipped upside down so we flip the sprite
	node.sprite.flipY = YES;
	node.type = kCCProgressTimerTypeBar;
	
	node.midpoint = ccp(.5f, .5f);
	node.barChangeRate = ccp(1, 1);
	
	node.percentage = 0;
	node.position = ccp(size.width/2, size.height/2);
	node.anchorPoint = ccp(0.5f,0.5f);
	
	return node;
}
@end

#pragma mark - CCTransitionProgressOutIn

@implementation CCTransitionProgressOutIn
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture
{	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	CCProgressTimer *node = [CCProgressTimer progressWithSprite:texture.sprite];
	
	// but it is flipped upside down so we flip the sprite
	node.sprite.flipY = YES;
	node.type = kCCProgressTimerTypeBar;
	
	node.midpoint = ccp(.5f, .5f);
	node.barChangeRate = ccp(1, 1);
	
	node.percentage = 100;
	node.position = ccp(size.width/2, size.height/2);
	node.anchorPoint = ccp(0.5f,0.5f);
	
	return node;
}
@end



