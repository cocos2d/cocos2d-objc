/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


/** @mainpage cocos2d for iPhone API reference
 *
 * @image html cocos2d-Icon.png
 *
 * @section intro Introduction
 * Here you will find the API reference
 *
 * <hr>
 *
 * @todo A native english speaker shall check the grammar. We need your help!
 *
 */

// 0x00 HI ME LO
// 00   00 05 00
#define COCOS2D_VERSION 0x00000500

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
