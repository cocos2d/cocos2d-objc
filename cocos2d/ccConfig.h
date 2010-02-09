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

/**
 @file
 cocos2d (cc) configuration file
*/

/**
 If enabled, FontLabel will be used to render .ttf files.
 If the .ttf file is not found, then it will use the standard UIFont class
 If disabled, the standard UIFont class will be used.
 */
#define CC_FONT_LABEL_SUPPORT	1

/**
 If enabled, the the FPS will be drawn using CCLabelAtlas (fast rendering).
 You will need to add the fps_images.png to your project.
 If disabled, the FPS will be rendered using Label (slow rendering)
 */
#define CC_DIRECTOR_FAST_FPS	1

/**
 Senconds between FPS updates.
 0.5 seconds, means that the FPS number will be updated every 0.5 seconds.
 Having a bigger number means a more reliable FPS
 */
#define CC_DIRECTOR_FPS_INTERVAL (0.1f)

/**
 If enabled, and only when it is used with FastDirector, the main loop will wait 0.04 seconds to
 dispatch all the events, even if there are not events to dispatch.
 If your game uses lot's of events (eg: touches) it might be a good idea to enable this feature.
 Otherwise, it is safe to leave it disabled.
 @warning This feature is experimental
 */
// #define CC_DIRECTOR_DISPATCH_FAST_EVENTS 1

/**
 If enabled, the CocosNode objects (Sprite,Label,etc) will be able to render in subpixels.
 If disabled, integer pixels will be used.
 */
#define CC_COCOSNODE_RENDER_SUBPIXEL 1

/**
 If enabled, the Sprites rendered with the SpriteSheet will be able to render in subpixels.
 If disabled, integer pixels will be used.
 */
#define CC_SPRITESHEET_RENDER_SUBPIXEL	1

/** 
 If enabled, the CCTextureAtlas object will use VBO instead of vertex list (recommended by Apple)
 @since v0.99.0
 */
#define CC_TEXTURE_ATLAS_USES_VBO 1

/**
 If enabled, CCNode will transform the nodes using a cached Affine matrix.
 If disabled, the node will be transformed using glTranslate,glRotate,glScale.
 Using the affine matrix only requires 2 GL calls.
 Using the translate/rotate/scale requires 5 GL calls.
 But computing the Affine matrix is relative expensive.
 But according to performance tests, Affine matrix performs better.
 This parameter doesn't affect SpriteSheet nodes.
 */
#define CC_NODE_TRANSFORM_USING_AFFINE_MATRIX 1

/**
 Use GL_TRIANGLE_STRIP instead of GL_TRIANGLES when rendering the texture atlas.
 It seems it is the recommend way, but it is much slower, so, enable it at your own risk
 */
//#define CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP 1

/**
 If enabled, all subclasses of CCSprite will draw a bounding box
 Useful for debugging purposes only.
 It is recommened to leave it disabled.
 */
//#define CC_SPRITE_DEBUG_DRAW 1

/**
 If enabled, all subclasses of CCSprite that are rendered using an CCSpriteSheet draw a bounding box.
 Useful for debugging purposes only.
 It is recommened to leave it disabled.
 */
//#define CC_SPRITESHEET_DEBUG_DRAW 1

/**
 If enabled, all subclasses of BitmapFontAtlas will draw a bounding box
 Useful for debugging purposes only.
 It is recommened to leave it disabled.
 */
//#define CC_BITMAPFONTATLAS_DEBUG_DRAW 1

/**
 If enabled, all subclasses of LabeltAtlas will draw a bounding box
 Useful for debugging purposes only.
 It is recommened to leave it disabled.
 */
//#define CC_LABELATLAS_DEBUG_DRAW 1

/**
 Enable it if you want to support v0.8 compatbility.
 Basically, classes without namespaces will work.
 It is recommended to disable compatibility once you have migrated your game to v0.9 to avoid class name polution
 */
//#define CC_COMPATIBILITY_WITH_0_8 1
