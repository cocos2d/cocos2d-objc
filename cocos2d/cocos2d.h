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


/** @mainpage cocos2d for iPhone API reference
 *
 * @image html cocos2d-Icon.png
 *
 * @section intro Introduction
 * cocos2d API reference
 *
 * <hr>
 *
 * @todo A native english speaker should check the grammar. We need your help!
 *
 */

// 0x00 HI ME LO
// 00   00 08 00
#define COCOS2D_VERSION 0x00000800

//
// all cocos2d include files
//
#import "Action.h"
#import "Camera.h"
#import "CameraAction.h"
#import "CocosNode.h"
#import "Director.h"
#import "TouchDispatcher.h"
#import "TouchDelegateProtocol.h"
#import "InstantAction.h"
#import "IntervalAction.h"
#import "EaseAction.h"
#import "Label.h"
#import "Layer.h"
#import "Menu.h"
#import "MenuItem.h"
#import "ParticleSystem.h"
#import "PointParticleSystem.h"
#import "QuadParticleSystem.h"
#import "ParticleExamples.h"
#import "Primitives.h"
#import "Scene.h"
#import "Scheduler.h"
#import "Sprite.h"
#import "TextureMgr.h"
#import "TextureNode.h"
#import "Transition.h"
#import "TextureAtlas.h"
#import "LabelAtlas.h"
#import "TileMapAtlas.h"
#import "AtlasNode.h"
#import "EaseAction.h"
#import "TiledGridAction.h"
#import "Grabber.h"
#import "Grid.h"
#import "Grid3DAction.h"
#import "GridAction.h"
#import "AtlasSprite.h"
#import "AtlasSpriteManager.h"
#import "BitmapFontAtlas.h"
#import "ParallaxNode.h"

//
// cocos2d macros
//
#import "ccTypes.h"
#import "ccMacros.h"

//
// cocos2d helper files
//
#import "Support/OpenGL_Internal.h"
#import "Support/Texture2D.h"
#import "Support/EAGLView.h"
#import "Support/FileUtils.h"
#import "Support/CGPointExtension.h"


// free functions
NSString * cocos2dVersion(void);
