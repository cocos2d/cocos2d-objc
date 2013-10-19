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

/**
 @file
 cocos2d (cc) configuration file
*/

/** @def CC_ENABLE_CHIPMUNK_INTEGRATION
 If enabled, it will include CCPhysicsScript and CCPhysicsDebugNode with Chipmunk Physics support.
 If you enable it, make sure that Chipmunk is in the search path.
 Disabled by default

 @since v2.1
 */
#ifndef CC_ENABLE_CHIPMUNK_INTEGRATION
#define CC_ENABLE_CHIPMUNK_INTEGRATION 0
#endif

/** @def CC_CHIPMUNK_IMPORT
 Which file to import if using Chipmunk.
 Change it to "ObjectiveChipmunk.h" or define it as a preprocessor macro if you are using ObjectiveChipmunk.
 @since v2.1
 */
#if CC_ENABLE_CHIPMUNK_INTEGRATION && !defined(CC_CHIPMUNK_IMPORT)
#define CC_CHIPMUNK_IMPORT "chipmunk.h"
#endif

/** @def CC_ENABLE_BOX2D_INTEGRATION
 If enabled, it will include CCPhysicsScript with Box2D Physics support.
 If you enable it, make sure that Box2D is in the search path.
 
 Disabled by default
 
 @since v2.1
 */
#ifndef CC_ENABLE_BOX2D_INTEGRATION
#define CC_ENABLE_BOX2D_INTEGRATION 0
#endif

/** @def CC_ENABLE_STACKABLE_ACTIONS
 If enabled, actions that alter the position property (eg: CCMoveBy, CCJumpBy, CCBezierBy, etc..) will be stacked.
 If you run 2 or more 'position' actions at the same time on a node, then end position will be the sum of all the positions. 
 If disabled, only the last run action will take effect.
 
 Enabled by default. Disable to be compatible with v2.0 and older versions.

 @since v2.1
 */
#ifndef CC_ENABLE_STACKABLE_ACTIONS
#define CC_ENABLE_STACKABLE_ACTIONS 1
#endif


/** @def CC_ENABLE_GL_STATE_CACHE
 If enabled, cocos2d will maintain an OpenGL state cache internally to avoid unnecessary switches.
 In order to use them, you have to use the following functions, instead of the the GL ones:
	- ccGLUseProgram() instead of glUseProgram()
	- ccGLDeleteProgram() instead of glDeleteProgram()
	- ccGLBlendFunc() instead of glBlendFunc()

 If this functionality is disabled, then ccGLUseProgram(), ccGLDeleteProgram(), ccGLBlendFunc() will call the GL ones, without using the cache.

 It is recommended to enable it whenever possible to improve speed.
 If you are migrating your code from GL ES 1.1, then keep it disabled. Once all your code works as expected, turn it on.

 Default value: Enabled by default

 @since v2.0.0
 */
#ifndef CC_ENABLE_GL_STATE_CACHE
#define CC_ENABLE_GL_STATE_CACHE 1
#endif

/** @def CC_ENABLE_DEPRECATED
 If enabled, cocos2d will compile all deprecated methods, classes and free functions. Also, renamed constants will be active as well.
 Enable it only when migrating a v1.0 or earlier v2.0 versions to the most recent cocos2d version.
 
 Default value: Enabled by default
 
 @since v2.0.0
 */
#ifndef CC_ENABLE_DEPRECATED
#define CC_ENABLE_DEPRECATED 1
#endif


/** @def CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
 If enabled, the texture coordinates will be calculated by using this formula:
   - texCoord.left = (rect.origin.x*2+1) / (texture.wide*2);
   - texCoord.right = texCoord.left + (rect.size.width*2-2)/(texture.wide*2);

 The same for bottom and top.

 This formula prevents artifacts by using 99% of the texture.
 The "correct" way to prevent artifacts is by using the spritesheet-artifact-fixer.py or a similar tool.

 Affected nodes:
	- CCSprite / CCSpriteBatchNode and subclasses: CCLabelBMFont, CCTMXLayer
	- CCLabelAtlas
	- CCParticleSystemQuad
	- CCTileMap

 To enabled set it to 1. Disabled by default.

 @since v0.99.5
 */
#ifndef CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
#define CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL 0
#endif

/** @def CC_DIRECTOR_STATS_INTERVAL
 Seconds between stats updates.
 0.5 seconds, means that the stats will be updated every 0.5 seconds.
 Having a bigger number means more stable stats

 Default value: 0.1f
 */
#ifndef CC_DIRECTOR_STATS_INTERVAL
#define CC_DIRECTOR_STATS_INTERVAL (0.1f)
#endif

/** @def CC_DIRECTOR_STATS_POSITION
 Position of the FPS

 Default: 0,0 (bottom-left corner)
 */
#ifndef CC_DIRECTOR_STATS_POSITION
#define CC_DIRECTOR_STATS_POSITION ccp(0,0)
#endif

/** @def CC_DIRECTOR_IOS_USE_BACKGROUND_THREAD
 If enabled, cocos2d-ios will run on a background thread. If disabled cocos2d-ios will run the main thread.

 To enable set it to a 1, to disable it set to 0. Disabled by default.

 Only valid for cocos2d-ios. Not supported on cocos2d-mac.
 
 This is an EXPERIMENTAL feature. Do not use it unless you are a developer.

 */
#ifndef CC_DIRECTOR_IOS_USE_BACKGROUND_THREAD
#define CC_DIRECTOR_IOS_USE_BACKGROUND_THREAD 0
#endif


#define CC_MAC_USE_DISPLAY_LINK_THREAD 0
#define CC_MAC_USE_OWN_THREAD 1
#define CC_MAC_USE_MAIN_THREAD 2

/** @def CC_DIRECTOR_MAC_THREAD
 cocos2d-mac can run on its own thread, on the Display Link thread, or in the  main thread.
 If you are developing a game, the Display Link or Own thread are the best alternatives.
 If you are developing an editor that uses AppKit, you might need to use the Main Thread (only if you are lazy and don't want to create a sync queue).

 Options:
	CC_MAC_USE_DISPLAY_LINK_THREAD  (default)
	CC_MAC_USE_OWN_THREAD
	CC_MAC_USE_MAIN_THREAD
 
 Only valid for cocos2d-mac. Not supported on cocos2d-ios.

 */
#ifndef CC_DIRECTOR_MAC_THREAD
#define CC_DIRECTOR_MAC_THREAD CC_MAC_USE_DISPLAY_LINK_THREAD
#endif

/** @def CC_NODE_RENDER_SUBPIXEL
 If enabled, the CCNode objects (CCSprite, CCLabel,etc) will be able to render in subpixels.
 If disabled, integer pixels will be used.

 To enable set it to 1. Enabled by default.
 */
#ifndef CC_NODE_RENDER_SUBPIXEL
#define CC_NODE_RENDER_SUBPIXEL 1
#endif

/** @def CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
 If enabled, the CCSprite objects rendered with CCSpriteBatchNode will be able to render in subpixels.
 If disabled, integer pixels will be used.

 To enable set it to 1. Enabled by default.
 */
#ifndef CC_SPRITEBATCHNODE_RENDER_SUBPIXEL
#define CC_SPRITEBATCHNODE_RENDER_SUBPIXEL	1
#endif

/** @def CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
 Use GL_TRIANGLE_STRIP instead of GL_TRIANGLES when rendering the texture atlas.
 It seems it is the recommend way, but it is much slower, so, enable it at your own risk

 To enable set it to a value different than 0. Disabled by default.

 */
#ifndef CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP
#define CC_TEXTURE_ATLAS_USE_TRIANGLE_STRIP 0
#endif

/** @def CC_TEXTURE_ATLAS_USE_VAO
 By default, CCTextureAtlas (used by many cocos2d classes) will use VAO (Vertex Array Objects).
 Apple recommends its usage but they might consume a lot of memory, specially if you use many of them.
 So for certain cases, where you might need hundreds of VAO objects, it might be a good idea to disable it.
 
 To disable it set it to 0. Enabled by default.
 
 */
#ifndef CC_TEXTURE_ATLAS_USE_VAO
#define CC_TEXTURE_ATLAS_USE_VAO 1
#endif


/** @def CC_SPRITE_DEBUG_DRAW
 If enabled, all subclasses of CCSprite will draw a bounding box.
 Useful for debugging purposes only. It is recommended to leave it disabled.

 If the CCSprite is being drawn by a CCSpriteBatchNode, the bounding box might be a bit different.
 To enable set it to a value different than 0. Disabled by default:
 0 -- disabled
 1 -- draw bounding box
 2 -- draw texture box
 */
#ifndef CC_SPRITE_DEBUG_DRAW
#define CC_SPRITE_DEBUG_DRAW 0
#endif


/** @def CC_LABELBMFONT_DEBUG_DRAW
 If enabled, all subclasses of CCLabelBMFont will draw a bounding box
 Useful for debugging purposes only. It is recommended to leave it disabled.

 To enable set it to a value different than 0. Disabled by default.
 */
#ifndef CC_LABELBMFONT_DEBUG_DRAW
#define CC_LABELBMFONT_DEBUG_DRAW 0
#endif

/** @def CC_LABELATLAS_DEBUG_DRAW
 If enabled, all subclasses of CCLabeltAtlas will draw a bounding box
 Useful for debugging purposes only. It is recommended to leave it disabled.

 To enable set it to a value different than 0. Disabled by default.
 */
#ifndef CC_LABELATLAS_DEBUG_DRAW
#define CC_LABELATLAS_DEBUG_DRAW 0
#endif

/** @def CC_ENABLE_PROFILERS
 If enabled, it will activate various profilers within cocos2d. This statistical data will be saved in the CCProfiler singleton.
 In order to display saved data, you have to call the CC_PROFILER_DISPLAY_TIMERS() macro.
 Useful for profiling purposes only. If unsure, leave it disabled.

 To enable set it to a value different than 0. Disabled by default.
 */
#ifndef CC_ENABLE_PROFILERS
#define CC_ENABLE_PROFILERS 0
#endif

