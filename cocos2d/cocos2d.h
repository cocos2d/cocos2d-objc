/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
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
// 00   00 99 00
#define COCOS2D_VERSION 0x00009900

//
// all cocos2d include files
//
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
#import "ccConfig.h"
#import "CCConfiguration.h"

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
#import "Support/ccArray.h"


// compatibility with v0.8
#import "CCCompatibility.h"


// free functions
NSString * cocos2dVersion(void);
