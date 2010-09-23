/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Lam Pham
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



#import "CCDirector.h"
#import "CCTransitionRadial.h"
#import "CCRenderTexture.h"
#import "CCLayer.h"
#import "CCActionInstant.h"
#import "Support/CGPointExtension.h"

enum {
	kSceneRadial = 0xc001,
};

#pragma mark -
#pragma mark Transition Radial CCW

@implementation CCTransitionRadialCCW
-(void) sceneOrder
{
	inSceneOnTop_ = NO;
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
	[outScene_ visit];
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
	CCActionInterval * layerAction = [CCSequence actions:
									  [CCProgressFromTo actionWithDuration:duration_ from:100.f to:0.f],
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

#pragma mark -
#pragma mark Transition Radial CW

@implementation CCTransitionRadialCW
-(CCProgressTimerType) radialType
{
	return kCCProgressTimerTypeRadialCW;
}
@end

