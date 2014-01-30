/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
 * Copyright (c) 2009 Robert J Payne
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
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
 *
 */

#import <Foundation/Foundation.h>
#import "CCSpriteFrame.h"

@class CCSprite;
@class CCTexture;

/**
 Singleton that manages the loading and caching of sprite frames.
 
 ### Supported editors (Non exhaustive)
 
 - Texture Packer http://www.codeandweb.com/texturepacker
 - zwoptex http://www.zwopple.com/zwoptex/
 */

@interface CCSpriteFrameCache : NSObject {
    
    // Sprite frame dictionary.
	NSMutableDictionary *_spriteFrames;
    
    // Sprite frame alias dictionary.
	NSMutableDictionary *_spriteFramesAliases;
    
    // Sprite frame plist file name set.
	NSMutableSet		*_loadedFilenames;
    
    // Sprite frame file lookup dictionary.
    NSMutableDictionary *_spriteFrameFileLookup;
}

/** Sprite frame cache shared instance. */
+ (CCSpriteFrameCache *) sharedSpriteFrameCache;

/** Purges the cache. It releases everything. */
+(void) purgeSharedSpriteFrameCache;


/// -----------------------------------------------------------------------
/// @name Sprite Frame Cache Addition
/// -----------------------------------------------------------------------

/**
 *  Add Sprite frames to the cache from the specified plist.
 *
 *  @param plist plist description.
 */
-(void) addSpriteFramesWithFile:(NSString*)plist;

/**
 *  Add sprite frames to the cache from the specified plist and texture file.
 *
 *  @param plist    Plist file to use.
 *  @param filename Texture file to associate.
 */
-(void) addSpriteFramesWithFile:(NSString*)plist textureFilename:(NSString*)filename;

/**
 *  Add sprite frames to the cache from the specified plist and texture.
 *
 *  @param plist   Plist file to use.
 *  @param texture Texture to associate.
 */
-(void) addSpriteFramesWithFile:(NSString*)plist texture:(CCTexture*)texture;

/**
 *  Add a sprite frame to the cache with the specified sprite frame and name.  If name already exists, sprite frame will be overwritten.
 *
 *  @param frame     Sprite frame to use.
 *  @param frameName Frame name to use.
 */
-(void) addSpriteFrame:(CCSpriteFrame*)frame name:(NSString*)frameName;

/**
 *  Registers a sprite sheet with the sprite frame cache so that the sprite frames can be loaded by name.
 *
 *  @param plist Sprite sheet file.
 */
-(void) registerSpriteFramesFile:(NSString*)plist;

/**
 *  Loads a sprite sheet lookup file and registers all the referenced sprite sheets with the sprite frame cache.
 *
 *  @param filename Sprite sheet lookup file.
 */
-(void) loadSpriteFrameLookupDictionaryFromFile:(NSString*)filename;

/// -----------------------------------------------------------------------
/// @name Sprite Frame Cache Removal
/// -----------------------------------------------------------------------

/**
 *  Remove all sprite frames.
 */
-(void) removeSpriteFrames;

/**
 *  Remove unused sprite frames e.g. Sprite frames that have a retain count of 1.
 */
-(void) removeUnusedSpriteFrames;

/**
 *  Remove the specified sprite frame from the cache.
 *
 *  @param name Sprite frame name.
 */
-(void) removeSpriteFrameByName:(NSString*)name;

/**
 *  Remove sprite frames detailed in the specified plist.
 *
 *  @param plist list file to use.
 */
-(void) removeSpriteFramesFromFile:(NSString*) plist;

/**
 *  Remove sprite frames associated with the specified texture.
 *
 *  @param texture Texture to reference.
 */
-(void) removeSpriteFramesFromTexture:(CCTexture*) texture;


/// -----------------------------------------------------------------------
/// @name Sprite Frame Cache Access
/// -----------------------------------------------------------------------

/**
 *  Returns a CCSpriteFrame from the cache using the specified name.
 *
 *  @param name Name to lookup.
 *
 *  @return The CCSpriteFrame object.
 */
-(CCSpriteFrame*) spriteFrameByName:(NSString*)name;

@end
