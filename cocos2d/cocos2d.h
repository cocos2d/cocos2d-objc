/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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
 */

/** @mainpage cocos2d for iPhone API reference
 *
 * @image html Icon.png
 *
 * @section intro Introduction
 * This is cocos2d API reference
 *
 * The programming guide is hosted here: http://www.cocos2d-iphone.org/wiki/doku.php/prog_guide:index
 *
 * <hr>
 *
 * @todo A native English speaker should check the grammar. We need your help!
 *
 */

// 0x00 HI ME LO
// 00   03 00 00
#define COCOS2D_VERSION 0x00030100

//
// all cocos2d include files
//
#import "ccConfig.h"	// should be included first

// Cocos2D
#import "CCAction.h"
#import "CCActionCatmullRom.h"
#import "CCActionEase.h"
#import "CCActionEase.h"
#import "CCActionInstant.h"
#import "CCActionInterval.h"
#import "CCActionProgressTimer.h"
#import "CCActionTween.h"
#import "CCClippingNode.h"
#import "CCColor.h"
#import "CCConfiguration.h"
#import "CCDirector.h"
#import "CCDrawNode.h"
#import "CCLabelBMFont.h"
#import "CCLabelTTF.h"
#import "CCMotionStreak.h"
#import "CCNode+Debug.h"
#import "CCNode.h"
#import "CCNodeColor.h"
#import "CCParallaxNode.h"
#import "CCParticleExamples.h"
#import "CCParticleSystem.h"
#import "CCProtocols.h"
#import "CCRenderTexture.h"
#import "CCScene.h"
#import "CCSprite.h"
#import "CCSprite9Slice.h"
#import "CCSpriteBatchNode.h"
#import "CCSpriteFrame.h"
#import "CCSpriteFrameCache.h"
#import "CCTMXXMLParser.h"
#import "CCTexture.h"
#import "CCTexturePVR.h"
#import "CCTiledMap.h"
#import "CCTiledMapLayer.h"
#import "CCTiledMapObjectGroup.h"
#import "CCTransition.h"
//#import "CCEffectNode.h" work in progress

// Layouts
#import "CCLayout.h"
#import "CCLayoutBox.h"

// Shaders
#import "CCShader.h"

// Physics
#import "CCPhysicsBody.h"
#import "CCPhysicsJoint.h"
#import "CCPhysicsNode.h"
#import "CCPhysicsShape.h"

// Sound
#import "OALSimpleAudio.h"

// Retiring
//#import "CCAnimation.h"
//#import "CCAnimationCache.h"
//#import "CCActionManager.h"
//#import "ccFPSImages.h"
//#import "CCAtlasNode.h"
//#import "CCLabelAtlas.h"
//#import "CCScheduler.h"
//#import "CCTextureCache.h"
//#import "CCTextureAtlas.h"


//
// cocos2d macros
//
#import "ccTypes.h"
#import "ccMacros.h"

// Platform common
#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"

#ifdef __CC_PLATFORM_IOS
#import "CCAppDelegate.h"
#import "Platforms/iOS/CCGLView.h"
#import "Platforms/iOS/CCDirectorIOS.h"
#import "Platforms/iOS/UITouch+CC.h"

#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCGLView.h"
#import "Platforms/Mac/CCDirectorMac.h"
#import "Platforms/Mac/CCWindow.h"
#import "Platforms/Mac/NSEvent+CC.h"
#endif

//
// cocos2d helper files
//
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/ccUtils.h"
#import "Support/CCProfiling.h"
#import "Support/NSThread+performBlock.h"
#import "Support/uthash.h"
#import "Support/utlist.h"



#ifdef __cplusplus
extern "C" {
#endif

// free functions
NSString * cocos2dVersion(void);
extern const char * cocos2d_version;

#ifdef __cplusplus
}
#endif

	
#ifdef __CC_PLATFORM_IOS
#ifndef __IPHONE_4_0
#error "If you are targeting iPad, you should set BASE SDK = 4.0 (or 4.1, or 4.2), and set the 'iOS deploy target' = 3.2"
#endif
#endif
