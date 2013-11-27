/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
 * Copyright (c) 2009 Robert J Payne
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
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


/// -----------------------------------------------------------------------
/// @name Sprite Frame Cache Management
/// -----------------------------------------------------------------------

/**
 *  Add Sprite Frames to the cache from the specified plist.
 *
 *  @param plist plist description
 */
-(void) addSpriteFramesWithFile:(NSString*)plist;

/** Adds multiple Sprite Frames from a plist file. The texture filename will be associated with the created sprite frames.
 */
-(void) addSpriteFramesWithFile:(NSString*)plist textureFilename:(NSString*)filename;

/** Adds multiple Sprite Frames from a plist file. The texture will be associated with the created sprite frames.
 */
-(void) addSpriteFramesWithFile:(NSString*)plist texture:(CCTexture*)texture;

/** Adds an sprite frame with a given name.
 If the name already exists, then the contents of the old name will be replaced with the new one.
 */
-(void) addSpriteFrame:(CCSpriteFrame*)frame name:(NSString*)frameName;


/** Purges the dictionary of loaded sprite frames.
 * Call this method if you receive the "Memory Warning".
 * In the short term: it will free some resources preventing your app from being killed.
 * In the medium term: it will allocate more resources.
 * In the long term: it will be the same.
 */
-(void) removeSpriteFrames;

/** Removes unused sprite frames.
 * Sprite Frames that have a retain count of 1 will be deleted.
 * It is convenient to call this method after when starting a new Scene.
 */
-(void) removeUnusedSpriteFrames;

/** Deletes an sprite frame from the sprite frame cache.
 */
-(void) removeSpriteFrameByName:(NSString*)name;

/** Removes multiple Sprite Frames from a plist file.
* Sprite Frames stored in this file will be removed.
* It is convenient to call this method when a specific texture needs to be removed.
* @since v0.99.5
*/
- (void) removeSpriteFramesFromFile:(NSString*) plist;

/** Removes all Sprite Frames associated with the specified textures.
 * It is convenient to call this method when a specific texture needs to be removed.
 * @since v0.995.
 */
- (void) removeSpriteFramesFromTexture:(CCTexture*) texture;

/** Returns an Sprite Frame that was previously added.
 If the name is not found it will return nil.
 You should retain the returned copy if you are going to use it.
 */
-(CCSpriteFrame*) spriteFrameByName:(NSString*)name;

/** Purges the cache. It releases everything. */
+(void) purgeSharedSpriteFrameCache;

-(void) registerSpriteFramesFile:(NSString*)plist;

-(void) loadSpriteFrameLookupDictionaryFromFile:(NSString*)filename;

@end
