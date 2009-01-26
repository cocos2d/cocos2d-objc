/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
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
// 00   00 06 02
#define COCOS2D_VERSION 0x00000603

//
// all cocos2d include files
//
#import "Action.h"
#import "Camera.h"
#import "CameraAction.h"
#import "CocosNode.h"
#import "Director.h"
#import "InstantAction.h"
#import "IntervalAction.h"
#import "EaseAction.h"
#import "Label.h"
#import "Layer.h"
#import "Menu.h"
#import "MenuItem.h"
#import "Particle.h"
#import "ParticleSystems.h"
#import "Primitives.h"
#import "Scene.h"
#import "Scheduler.h"
#import "Sprite.h"
#import "TextureMgr.h"
#import "TextureNode.h"
#import "Transition.h"
#import "types.h"
#import "TextureAtlas.h"
#import "LabelAtlas.h"
#import "TileMapAtlas.h"
#import "AtlasNode.h"

//
// cocos2d helper files
//
#import "Support/OpenGL_Internal.h"
#import "Support/Texture2D.h"
#import "Support/EAGLView.h"


// free functions
NSString * cocos2dVersion(void);
