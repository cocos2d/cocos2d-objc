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

/**
 @file
 cocos2d (cc) configuration file
*/

// Used to just plain deprecate stuff
#define CC_DEPRECATED(msg) __attribute((deprecated((msg))))

// Used to deprecate stuff, if compiled for -x compatibility
#ifdef COCOS2D_X_COMPATIBLE
#define CC_DEPRECATED_X(msg) __attribute((deprecated((msg))))
#else
#define CC_DEPRECATED_X(msg)
#endif



/** @def CC_ENABLE_STACKABLE_ACTIONS
 If enabled, actions that alter the position property (eg: CCMoveBy, CCJumpBy, CCBezierBy, etc..) will be stacked.
 If you run 2 or more 'position' actions at the same time on a node, then end position will be the sum of all the positions. 
 If disabled, only the last run action will take effect.
 
 Enabled by default. Disable to be compatible with v2.0 and older versions.

 */
#ifndef CC_ENABLE_STACKABLE_ACTIONS
#define CC_ENABLE_STACKABLE_ACTIONS 1
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
#define CC_DIRECTOR_MAC_THREAD CC_MAC_USE_MAIN_THREAD
#endif

/**
	Enable multi-threaded rendering on iOS.
	Only valid for cocos2d-iOS. See CCGLQueue.h for more information.
	*/
#ifndef CC_DIRECTOR_IOS_THREADED_RENDERING
#define CC_DIRECTOR_IOS_THREADED_RENDERING 0
#endif

/** @def CC_NODE_RENDER_SUBPIXEL
 If enabled, the CCNode objects (CCSprite, CCLabel,etc) will be able to render in subpixels.
 If disabled, integer pixels will be used.

 To enable set it to 1. Enabled by default.
 */
#ifndef CC_NODE_RENDER_SUBPIXEL
#define CC_NODE_RENDER_SUBPIXEL 1
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

/** @def CC_ENABLE_METAL_RENDERING
 Enable rendering using Apple's Metal graphics API on supported platforms and hardware.
 This can reduce the cost of rendering unbatched geometry, but not all Cocos2D features are supported.
 */
#ifndef CC_ENABLE_METAL_RENDERING
#define CC_ENABLE_METAL_RENDERING 0
#endif

#ifndef CC_SHADER_COLOR_PRECISION
#define CC_SHADER_COLOR_PRECISION lowp
#endif

#ifndef CC_SHADER_DEFAULT_FRAGMENT_PRECISION
#define CC_SHADER_DEFAULT_FRAGMENT_PRECISION mediump
#endif

#ifndef CC_EFFECTS_EXPERIMENTAL
#define CC_EFFECTS_EXPERIMENTAL 0
#endif

