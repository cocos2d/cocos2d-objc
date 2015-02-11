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
// 00   03 01 01
#define COCOS2D_VERSION 0x00030403
#define COCOS2D_BUILD @"develop"


#import "ccConfig.h"

#import "ccTypes.h"
#import "ccMacros.h"

#import "Platforms/CCGL.h"

// Singletons:
#import "CCDirector.h"
#import "CCSpriteFrameCache.h"

// Basic Types:
#import "CCProtocols.h"
#import "CCColor.h"
#import "CCImage.h"
#import "CCTexture.h"
#import "CCSpriteFrame.h"
#import "CCShader.h"
#import "CCResponder.h"
#import "CCTouch.h"
#import "CCTouchEvent.h"

// Basic Node Types:
#import "CCNode.h"
#import "CCScene.h"
#import "CCRenderableNode.h"
#import "CCNodeColor.h"
#import "CCSprite.h"

// Misc Nodes:
#import "CCRenderTexture.h"
#import "CCSprite9Slice.h"
#import "CCLabelBMFont.h"
#import "CCLabelTTF.h"
#import "CCParticleSystem.h"
#import "CCDrawNode.h"
#import "CCClippingNode.h"
#import "CCMotionStreak.h"
#import "CCLayout.h"
#import "CCLayoutBox.h"

// Tilemaps:
#import "CCTMXXMLParser.h"
#import "CCTiledMap.h"
#import "CCTiledMapLayer.h"
#import "CCTiledMapObjectGroup.h"

// CCEffects:
#import "CCEffect.h"
#import "CCEffectBloom.h"
#import "CCEffectBrightness.h"
#import "CCEffectColorChannelOffset.h"
#import "CCEffectContrast.h"
#import "CCEffectBlur.h"
#import "CCEffectGlass.h"
#import "CCEffectDropShadow.h"
#import "CCEffectHue.h"
#import "CCEffectLighting.h"
#import "CCEffectNode.h"
#import "CCEffectPixellate.h"
#import "CCEffectReflection.h"
#import "CCEffectRefraction.h"
#import "CCEffectSaturation.h"
#import "CCEffectStack.h"
#import "CCLightNode.h"
#import "CCEffectOutline.h"

#if CC_EFFECTS_EXPERIMENTAL
#import "CCEffectOutline.h"
#import "CCEffectDFOutline.h"
#import "CCEffectDistanceField.h"
#import "CCEffectDFInnerGlow.h"
#endif

// Actions:
#import "CCAction.h"
#import "CCActionCatmullRom.h"
#import "CCActionEase.h"
#import "CCActionEase.h"
#import "CCActionInstant.h"
#import "CCActionInterval.h"
#import "CCActionProgressTimer.h"
#import "CCActionTween.h"

// Animations:
#import "CCAnimation.h"
#import "CCAnimationCache.h"

// Physics
#import "CCPhysicsBody.h"
#import "CCPhysicsJoint.h"
#import "CCPhysicsNode.h"
#import "CCPhysicsShape.h"

// Misc:
#import "CCRenderDispatch.h"
#import "CCTransition.h"
#import "CCPackage.h"
#import "CCDeviceInfo.h"
#import "CCFile.h"
#import "Support/CCFileUtils.h"
#import "Support/CGPointExtension.h"
#import "Support/ccUtils.h"
#import "Support/uthash.h"
#import "Support/utlist.h"
#import "UITouch+CC.h"
#import "NSEvent+CC.h"
#import "CCDeprecated.h"
#import "CCScheduler.h"

// UI
#import "cocos2d-ui.h"

// Sound
#import "OALSimpleAudio.h"

// Platform Support:
#import "Platforms/CCNS.h"

#if __CC_PLATFORM_IOS
#import "CCAppDelegate.h"
#import "Platforms/iOS/CCViewiOSGL.h"
#import "Platforms/iOS/CCDirectorIOS.h"
#elif __CC_PLATFORM_MAC
#import "Platforms/Mac/CCViewMacGL.h"
#import "Platforms/Mac/CCDirectorMac.h"
#import "Platforms/Mac/CCWindow.h"
#import "Platforms/Mac/NSEvent+CC.h"
#elif __CC_PLATFORM_ANDROID
#import "Platforms/Android/CCActivity.h"
#import "Platforms/Android/CCGLView.h"
#import "Platforms/Android/CCDirectorAndroid.h"

#import <android/native_window.h>
#import <bridge/runtime.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

// free functions
NSString * cocos2dVersion(void);

#ifdef __cplusplus
}
#endif
