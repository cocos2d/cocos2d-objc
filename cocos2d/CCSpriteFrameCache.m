/*
 * Cocos2D-SpriteBuilder: http://cocos2d.spritebuilder.com
 *
 * Copyright (c) 2009 Jason Booth
 * Copyright (c) 2009 Robert J Payne
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
 *
 */

/*
 * To create sprite frames and texture atlas, use any of these tools:
 * http://zwoptexapp.com/
 * http://www.texturepacker.com/
 *
 */

#import "Platforms/CCNS.h"
#import "ccMacros.h"

#import "CCTexture_Private.h"
#import "CCSpriteFrameCache_Private.h"
#import "CCFileLocator_Private.h"

#import "CCTextureCache.h"
#import "CCSpriteFrame.h"
#import "CCSprite.h"
#import "CCFile.h"
#import "ccUtils.h"


@interface CCSpriteFrame(Cache)

- (BOOL)hasProxy;
- (CCProxy *)proxy;

@property (nonatomic, copy) NSString *textureFilename;

@end


@implementation CCSpriteFrameCache {
    // Sprite frame dictionary.
	NSMutableDictionary *_spriteFrames;
    
    // Sprite frame plist file name set.
	NSMutableSet *_loadedFilenames;
    
    // Sprite frame file lookup dictionary.
    NSMutableDictionary *_spriteFrameFileLookup;
}

#pragma mark CCSpriteFrameCache - Alloc, Init & Dealloc

static CCSpriteFrameCache *_sharedSpriteFrameCache=nil;

+ (CCSpriteFrameCache *)sharedSpriteFrameCache
{
	if (!_sharedSpriteFrameCache)
		_sharedSpriteFrameCache = [[CCSpriteFrameCache alloc] init];

	return _sharedSpriteFrameCache;
}

+(id)alloc
{
	NSAssert(_sharedSpriteFrameCache == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedSpriteFrameCache
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
}

-(id) init
{
	if( (self=[super init]) ) {
		_spriteFrames = [[NSMutableDictionary alloc] initWithCapacity: 100];
		_loadedFilenames = [[NSMutableSet alloc] initWithCapacity:30];
		_spriteFrameFileLookup = [[NSMutableDictionary alloc] init];
	}

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | num of sprite frames =  %lu>", [self class], self, (unsigned long)[_spriteFrames count]];
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
}

#pragma mark CCSpriteFrameCache - registering sprite sheets

- (void) registerSpriteFramesFile:(NSString*)plistFile
{
    NSError *err = nil;
    
    CCFile *file = [[CCFileLocator sharedFileLocator] fileNamedWithResolutionSearch:plistFile error:&err];
    NSAssert(err == nil, @"Error finding %@: %@", plistFile, err);
    
    NSDictionary *dict = [file loadPlist:&err];
    NSAssert(err == nil, @"Error loading %@: %@", plistFile, err);
    
    NSDictionary *metadataDict = [dict objectForKey:@"metadata"];
	NSDictionary *framesDict = [dict objectForKey:@"frames"];
    
	int format = 0;
    
	// get the format
	if(metadataDict != nil)
		format = [[metadataDict objectForKey:@"format"] intValue];
    
	// check the format
	NSAssert( format >= 0 && format <= 3, @"format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:textureFilename:");
    
    for(NSString *frameDictKey in framesDict)
    {
        [_spriteFrameFileLookup setObject:plistFile forKey:frameDictKey];
    }
}

#pragma mark CCSpriteFrameCache - loading sprite frames

static CCSpriteFrame *MakeFrame(CGRect rect, BOOL rotated, CGPoint offset, CGSize untrimmedSize, CGFloat textureHeight, CGFloat contentScale)
{
    // Flip the y values before scaling.
    CGFloat h = (rotated ? rect.size.width : rect.size.height);
    rect.origin.y = textureHeight - (rect.origin.y + h);
    
	rect = CC_RECT_SCALE(rect, 1.0/contentScale);
    offset = ccpMult(offset, 1.0/contentScale);
    untrimmedSize = CC_SIZE_SCALE(untrimmedSize, 1.0/contentScale);
    
    return [[CCSpriteFrame alloc] initWithTexture:nil rect:rect rotated:rotated trimOffset:offset untrimmedSize:untrimmedSize];
}

static CCSpriteFrame *
SpriteFrameFromDict(int format, NSDictionary *frameDict, NSArray **aliases, CGFloat textureHeight, CGFloat contentScale)
{
    // Formats 0 and 1 are very old. I think both are pre-v1.0.
    // I (slembcke) removed support for them in v4. If you are using a version of TexturePacker from 2010, you'll have to update, sorry.
    // Format 2 seems to be used consistently from v1.0 and on. (Used by TexturePacker and SpriteBuilder)
    // Format 3 is only used by Zwoptex AFAIK.
    
    if(format == 2) {
        CGRect rect = CCRectFromString([frameDict objectForKey:@"frame"]);
        BOOL rotated = [[frameDict objectForKey:@"rotated"] boolValue];
        CGPoint offset = CCPointFromString([frameDict objectForKey:@"offset"]);
        CGSize untrimmedSize = CCSizeFromString([frameDict objectForKey:@"sourceSize"]);

        return MakeFrame(rect, rotated, offset, untrimmedSize, textureHeight, contentScale);
    } else if(format == 3) {
        CGSize spriteSize = CCSizeFromString([frameDict objectForKey:@"spriteSize"]);
        CGRect textureRect = CCRectFromString([frameDict objectForKey:@"textureRect"]);
        
        CGRect rect = {textureRect.origin, spriteSize};
        CGPoint offset = CCPointFromString([frameDict objectForKey:@"spriteOffset"]);
        CGSize untrimmedSize = CCSizeFromString([frameDict objectForKey:@"spriteSourceSize"]);
        BOOL rotated = [[frameDict objectForKey:@"textureRotated"] boolValue];
        
        (*aliases) = [frameDict objectForKey:@"aliases"];

        return MakeFrame(rect, rotated, offset, untrimmedSize, textureHeight, contentScale);
    } else {
        return nil;
    }
}

-(void)addSpriteFrame:(CCSpriteFrame *)frame name:(NSString *)frameName pathPrefix:(NSString *)pathPrefix
{
    _spriteFrames[frameName] = frame;

    // Add an alias that allows spriteframe files to be treated as directories.
    // Ex: A frame named "bar.png" in a spritesheet named "bar.plist" will add both "bar.png" and "foo/bar.png" to the dictionary.
    if(pathPrefix && ![frameName hasPrefix:pathPrefix]){
        NSString *key = [pathPrefix stringByAppendingPathComponent:frameName];
        _spriteFrames[key] = frame;
    }
}

-(void) addSpriteFramesWithFile:(NSString*)plistFile
{
	NSAssert(plistFile, @"plist filename should not be nil");
	
	if( ! [_loadedFilenames member:plistFile] ) {
        NSError *err = nil;
        
        CCFile *file = [[CCFileLocator sharedFileLocator] fileNamedWithResolutionSearch:plistFile error:&err];
        NSAssert(err == nil, @"Error finding %@: %@", plistFile, err);
        
        NSDictionary *dict = [file loadPlist:&err];
        NSAssert(err == nil, @"Error loading %@: %@", plistFile, err);
        
		NSDictionary *metadata = dict[@"metadata"];
        NSAssert(metadata, @"File did not have a metadata dictionary. (%@)", plistFile);
        
        NSString *textureFilename = metadata[@"textureFileName"];
        NSAssert(textureFilename, @"File did not contain a textureFileName.", plistFile);
        
        // build texture path relative to plist file
        NSString *textureBase = [plistFile stringByDeletingLastPathComponent];
        NSString *texturePath = [textureBase stringByAppendingPathComponent:textureFilename];
        
        int format = [metadata[@"format"] intValue];
        NSAssert( format >= 2 && format <= 3, @"Format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:textureFilename:");
        
        CGSize textureSize = CCSizeFromString(metadata[@"size"]);
        CGFloat contentScale = file.contentScale;
        
        NSDictionary *framesDict = dict[@"frames"];
        NSAssert(framesDict, @"Frames dictionary not found!");
        
        // Prefix to append on the front of cached frame names.
        // This is for supporting transparent atlas files.
        // (Ex: Foobar/Sprites/Hero.png will use Hero.png from an atlas named Foobar/Sprites.plist)
        NSString *pathPrefix = [plistFile stringByDeletingPathExtension];
        
        for(NSString *name in framesDict) {
            NSArray *aliases = nil;
            
            CCSpriteFrame *frame = SpriteFrameFromDict(format, framesDict[name], &aliases, textureSize.height, contentScale);
            frame.textureFilename = texturePath;
            
            [self addSpriteFrame:frame name:name pathPrefix:pathPrefix];
            for(NSString *alias in aliases){
                [self addSpriteFrame:frame name:alias pathPrefix:pathPrefix];
            }
        }
        
		[_loadedFilenames addObject:plistFile];
	} else {
		CCLOGINFO(@"cocos2d: CCSpriteFrameCache: file already loaded: %@", plist);
    }
}

-(void) addSpriteFrame:(CCSpriteFrame*)frame name:(NSString*)frameName
{
	[_spriteFrames setObject:frame forKey:frameName];
}

#pragma mark CCSpriteFrameCache - removing

-(void) removeSpriteFrames
{
	[_spriteFrames removeAllObjects];
	[_loadedFilenames removeAllObjects];
}

-(void) removeUnusedSpriteFrames
{
		for(id key in [_spriteFrames allKeys])
		{
				CCSpriteFrame *frame = _spriteFrames[key];
				CCLOGINFO(@"sprite frame(%@): %@", key, frame);
				// If the weakly retained proxy object is nil, then the texture is unreferenced.
				if (!frame.hasProxy)
				{
						CCLOGINFO(@"cocos2d: CCSpriteFrameCache: removing unused sprite frame: %@", key);
						[_spriteFrames removeObjectForKey:key];
				}
		}
		CCLOGINFO(@"Purge complete.");
}

-(void) removeSpriteFrameByName:(NSString*)name
{
	// explicit nil handling
	if( ! name ) return;

    [_spriteFrames removeObjectForKey:name];
	
	// XXX. Since we don't know the .plist file that originated the frame, we must remove all .plist from the cache
	[_loadedFilenames removeAllObjects];
}

- (void) removeSpriteFramesFromFile:(NSString*) plistFile
{
    NSError *err = nil;
    
    CCFile *file = [[CCFileLocator sharedFileLocator] fileNamed:plistFile error:&err];
    NSAssert(err == nil, @"Error finding %@: %@", plistFile, err);
    
    NSDictionary *dict = [file loadPlist:&err];
    NSAssert(err == nil, @"Error loading %@: %@", plistFile, err);

	[self removeSpriteFramesFromDictionary:dict];
	
	// remove it from the cache
	id ret = [_loadedFilenames member:plistFile];
	if( ret )
		[_loadedFilenames removeObject:ret];
}

- (void) removeSpriteFramesFromDictionary:(NSDictionary*) dictionary
{
	NSDictionary *framesDict = [dictionary objectForKey:@"frames"];
	NSMutableArray *keysToRemove=[NSMutableArray array];

	for(NSString *frameDictKey in framesDict)
	{
		if ([_spriteFrames objectForKey:frameDictKey]!=nil)
			[keysToRemove addObject:frameDictKey];
	}
	[_spriteFrames removeObjectsForKeys:keysToRemove];
}

- (void) removeSpriteFramesFromTexture:(CCTexture*) texture
{
	NSMutableArray *keysToRemove=[NSMutableArray array];

	for (NSString *spriteFrameKey in _spriteFrames)
	{
		if ([[_spriteFrames valueForKey:spriteFrameKey] texture] == texture)
			[keysToRemove addObject:spriteFrameKey];

	}
	[_spriteFrames removeObjectsForKeys:keysToRemove];
}

#pragma mark CCSpriteFrameCache - getting

-(CCSpriteFrame *) spriteFrameByName:(NSString*)name
{
    // TODO Use the FileLocator name alias.
//        name = [[CCFileUtils sharedFileUtils].filenameLookup objectForKey:name] ?: name;
    
    // Check to see if the frame is already in the cache.
    CCSpriteFrame *frame = _spriteFrames[name];
    
    // TODO Find a better way to suppress the search failure than to search twice.
    CCFile *file = [[CCFileLocator sharedFileLocator] fileNamed:name options:@{CCFILELOCATOR_SEARCH_OPTION_NOTRACE: @(YES)} error:nil trace:NO];
    if(file){
        CCTexture *texture = [CCTexture textureWithFile:name];
        NSAssert(texture, @"Found a file but it couldn't be loaded?");
        
        return texture.spriteFrame;
    }
    
    // Search for spritesheets by breaking down the spriteframe's name into paths.
    if(frame == nil){
        NSArray *pathComponents = [name pathComponents];
        for(NSUInteger len = pathComponents.count - 1; len > 0; len--){
            NSString *subpath = [NSString pathWithComponents:[pathComponents subarrayWithRange:NSMakeRange(0, len)]];
            NSString *path = [subpath stringByAppendingPathExtension:@"plist"];
            
            CCFile *file = [[CCFileLocator sharedFileLocator] fileNamed:path options:@{CCFILELOCATOR_SEARCH_OPTION_NOTRACE: @(YES)} error:nil trace:NO];
            if(file){
                [self addSpriteFramesWithFile:path];
                frame = _spriteFrames[name];
                
                if(frame) break;
            }
        }
    }
    
	return (CCSpriteFrame *)frame.proxy;
}

@end
