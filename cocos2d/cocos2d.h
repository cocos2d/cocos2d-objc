/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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
// 00   00 99 04
#define COCOS2D_VERSION 0x00009904

//
// all cocos2d include files
//
#import "ccConfig.h"	// should be included first

#import "CCBlockSupport.h"
#import "CCAction.h"
#import "CCCamera.h"
#import "CCCameraAction.h"
#import "CCProtocols.h"
#import "CCNode.h"
#import "CCDirector.h"
#import "CCTouchDispatcher.h"
#import "CCTouchDelegateProtocol.h"
#import "CCInstantAction.h"
#import "CCIntervalAction.h"
#import "CCEaseAction.h"
#import "CCLabel.h"
#import "CCLayer.h"
#import "CCMenu.h"
#import "CCMenuItem.h"
#import "CCParticleSystem.h"
#import "CCPointParticleSystem.h"
#import "CCQuadParticleSystem.h"
#import "CCParticleExamples.h"
#import "CCDrawingPrimitives.h"
#import "CCScene.h"
#import "CCScheduler.h"
#import "CCSprite.h"
#import "CCSpriteFrame.h"
#import "CCSpriteSheet.h"
#import "CCSpriteFrameCache.h"
#import "CCTextureCache.h"
#import "CCTransition.h"
#import "CCTextureAtlas.h"
#import "CCLabelAtlas.h"
#import "CCAtlasNode.h"
#import "CCEaseAction.h"
#import "CCTiledGridAction.h"
#import "CCGrabber.h"
#import "CCGrid.h"
#import "CCGrid3DAction.h"
#import "CCGridAction.h"
#import "CCBitmapFontAtlas.h"
#import "CCParallaxNode.h"
#import "CCActionManager.h"
#import "CCTMXTiledMap.h"
#import "CCTMXLayer.h"
#import "CCTMXObjectGroup.h"
#import "CCTMXXMLParser.h"
#import "CCTileMapAtlas.h"
#import "CCRenderTexture.h"
#import "CCMotionStreak.h"
#import "CCPageTurn3DAction.h"
#import "CCPageTurnTransition.h"
#import "CCTexture2D.h"
#import "CCPVRTexture.h"
#import "CCTouchHandler.h"
#import "CCConfiguration.h"
#import "CCRadialTransition.h"
#import "CCProgressTimerActions.h"
#import "CCPropertyAction.h"

//
// cocos2d macros
//
#import "ccTypes.h"
#import "ccMacros.h"

//
// cocos2d helper files
//
#import "Support/OpenGL_Internal.h"
#import "Support/EAGLView.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/ccCArray.h"
#import "Support/CCArray.h"

#if CC_ENABLE_PROFILERS
#import "Support/CCProfiling.h"
#endif // CC_ENABLE_PROFILERS


// compatibility with v0.8
#import "CCCompatibility.h"


// free functions
NSString * cocos2dVersion(void);
