/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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
 * @todo A native english speaker should check the grammar. We need your help!
 *
 */

// 0x00 HI ME LO
// 00   01 01 00
#define COCOS2D_VERSION 0x00010100

#import <Availability.h>

//
// all cocos2d include files
//
#import "ccConfig.h"	// should be included first

#import "CCActionManager.h"
#import "CCAction.h"
#import "CCActionInstant.h"
#import "CCActionInterval.h"
#import "CCActionEase.h"
#import "CCActionCamera.h"
#import "CCActionTween.h"
#import "CCActionEase.h"
#import "CCActionTiledGrid.h"
#import "CCActionGrid3D.h"
#import "CCActionGrid.h"
#import "CCActionProgressTimer.h"
#import "CCActionPageTurn3D.h"

#import "CCAnimation.h"
#import "CCAnimationCache.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCSpriteBatchNode.h"
#import "CCSpriteFrameCache.h"

#import "CCLabelTTF.h"
#import "CCLabelBMFont.h"
#import "CCLabelAtlas.h"

#import "CCParticleSystem.h"
#import "CCParticleSystemPoint.h"
#import "CCParticleSystemQuad.h"
#import "CCParticleExamples.h"
#import "CCParticleBatchNode.h"

#import "CCTexture2D.h"
#import "CCTexturePVR.h"
#import "CCTextureCache.h"
#import "CCTextureAtlas.h"

#import "CCTransition.h"
#import "CCTransitionPageTurn.h"
#import "CCTransitionRadial.h"

#import "CCTMXTiledMap.h"
#import "CCTMXLayer.h"
#import "CCTMXObjectGroup.h"
#import "CCTMXXMLParser.h"
#import "CCTileMapAtlas.h"

#import "CCLayer.h"
#import "CCMenu.h"
#import "CCMenuItem.h"
#import "CCDrawingPrimitives.h"
#import "CCScene.h"
#import "CCScheduler.h"
#import "CCBlockSupport.h"
#import "CCCamera.h"
#import "CCProtocols.h"
#import "CCNode.h"
#import "CCDirector.h"
#import "CCAtlasNode.h"
#import "CCGrabber.h"
#import "CCGrid.h"
#import "CCParallaxNode.h"
#import "CCRenderTexture.h"
#import "CCMotionStreak.h"
#import "CCConfiguration.h"

//
// cocos2d macros
//
#import "ccTypes.h"
#import "ccMacros.h"

#import "CCDrawNode.h"

//
// Physics integration
//
// Box2d integration should include these 2 files manually
#if CC_ENABLE_CHIPMUNK_INTEGRATION
#import "CCPhysicsDebugNode.h"
#import "CCPhysicsSprite.h"
#endif 

// Platform common
#import "Platforms/CCGL.h"
#import "Platforms/CCNS.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "Platforms/iOS/CCTouchDispatcher.h"
#import "Platforms/iOS/CCTouchDelegateProtocol.h"
#import "Platforms/iOS/CCTouchHandler.h"
#import "Platforms/iOS/EAGLView.h"
#import "Platforms/iOS/CCDirectorIOS.h"

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import "Platforms/Mac/MacGLView.h"
#import "Platforms/Mac/CCDirectorMac.h"
#endif

//
// cocos2d helper files
//
#import "Support/OpenGL_Internal.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/ccCArray.h"
#import "Support/CCArray.h"
#import "Support/ccUtils.h"

#if CC_ENABLE_PROFILERS
#import "Support/CCProfiling.h"
#endif // CC_ENABLE_PROFILERS


// free functions
NSString * cocos2dVersion(void);

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#ifndef __IPHONE_4_0
#error "If you are targeting iPad, you should set BASE SDK = 4.0 (or 4.1, or 4.2), and set the 'iOS deploy target' = 3.2"
#endif
#endif
