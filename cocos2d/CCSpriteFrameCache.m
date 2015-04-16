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
#import "CCTextureCache.h"
#import "CCSpriteFrameCache_Private.h"
#import "CCSpriteFrame.h"
#import "CCSprite.h"
#import "CCFileLocator_Private.h"
#import "CCFile.h"
#import "CCTexture_Private.h"


@interface CCSpriteFrame(Proxy)
- (BOOL)hasProxy;
- (CCProxy *)proxy;
@end


@implementation CCSpriteFrameCache {
    // Sprite frame dictionary.
	NSMutableDictionary *_spriteFrames;
    
    // Sprite frame alias dictionary.
	NSMutableDictionary *_spriteFramesAliases;
    
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
		_spriteFramesAliases = [[NSMutableDictionary alloc] initWithCapacity:10];
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

-(void) loadSpriteFrameLookupDictionaryFromFile:(NSString*)plistFile
{
    NSError *err = nil;
    
    CCFile *file = [[CCFileLocator sharedFileLocator] fileNamed:plistFile error:&err];
    NSAssert(err == nil, @"Error finding %@: %@", plistFile, err);
    
    NSDictionary *dict = [file loadPlist:&err];
    NSAssert(err == nil, @"Error loading %@: %@", plistFile, err);
    
    NSDictionary *metadata = [dict objectForKey:@"metadata"];
    NSInteger version = [[metadata objectForKey:@"version"] integerValue];
    if( version != 1) {
        CCLOG(@"cocos2d: ERROR: Invalid filenameLookup dictionary version: %ld. Filename: %@", (long)version, plistFile);
        return;
    }
    
    NSArray *spriteFrameFiles = [dict objectForKey:@"spriteFrameFiles"];
    for (NSString* spriteFrameFile in spriteFrameFiles)
    {
        [self registerSpriteFramesFile:spriteFrameFile];
    }
}

- (void)loadSpriteFrameLookupsInAllSearchPathsWithName:(NSString *)filename
{
    NSAssert(NO, @"Needs to be removed from v4");
//    NSArray *paths = [[CCFileUtils sharedFileUtils] fullPathsOfFileNameInAllSearchPaths:filename];
//
//    for (NSString *spriteFrameLookupFullPath in paths)
//    {
//        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:spriteFrameLookupFullPath];
//
//        NSDictionary *metadata = dict[@"metadata"];
//        NSInteger version = [metadata[@"version"] integerValue];
//        if (version != 1)
//        {
//            CCLOG(@"cocos2d: ERROR: Invalid filenameLookup dictionary version: %ld. Filename: %@", (long) version, filename);
//            return;
//        }
//
//        NSArray *spriteFrameFiles = dict[@"spriteFrameFiles"];
//        for (NSString *spriteFrameFile in spriteFrameFiles)
//        {
//            [self registerSpriteFramesFile:spriteFrameFile];
//        }
//    }
}

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

-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary textureReference:(id)textureReference prefix:(NSString *)pathPrefix
{
	/*
	 Supported Zwoptex Formats:
	 ZWTCoordinatesFormatOptionXMLLegacy = 0, // Flash Version
	 ZWTCoordinatesFormatOptionXML1_0 = 1, // Desktop Version 0.0 - 0.4b
	 ZWTCoordinatesFormatOptionXML1_1 = 2, // Desktop Version 1.0.0 - 1.0.1
	 ZWTCoordinatesFormatOptionXML1_2 = 3, // Desktop Version 1.0.2+
	*/
	NSDictionary *metadataDict = [dictionary objectForKey:@"metadata"];
	NSDictionary *framesDict = [dictionary objectForKey:@"frames"];

	int format = 0;

	// get the format
	if(metadataDict != nil)
		format = [[metadataDict objectForKey:@"format"] intValue];

	// check the format
	NSAssert( format >= 0 && format <= 3, @"format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:textureFilename:");

	// SpriteFrame info
	CGRect rectInPixels;
	BOOL isRotated;
	CGPoint frameOffset;
	CGSize originalSize;

	// add real frames
	for(NSString *frameDictKey in framesDict) {
		NSDictionary *frameDict = [framesDict objectForKey:frameDictKey];
		CCSpriteFrame *spriteFrame=nil;
		if(format == 0) {
			float x = [[frameDict objectForKey:@"x"] floatValue];
			float y = [[frameDict objectForKey:@"y"] floatValue];
			float w = [[frameDict objectForKey:@"width"] floatValue];
			float h = [[frameDict objectForKey:@"height"] floatValue];
			float ox = [[frameDict objectForKey:@"offsetX"] floatValue];
			float oy = [[frameDict objectForKey:@"offsetY"] floatValue];
			int ow = [[frameDict objectForKey:@"originalWidth"] intValue];
			int oh = [[frameDict objectForKey:@"originalHeight"] intValue];
			// check ow/oh
			if(!ow || !oh)
				CCLOGWARN(@"cocos2d: WARNING: originalWidth/Height not found on the CCSpriteFrame. AnchorPoint won't work as expected. Regenerate the .plist");

			// abs ow/oh
			ow = abs(ow);
			oh = abs(oh);

			// set frame info
			rectInPixels = CGRectMake(x, y, w, h);
			isRotated = NO;
			frameOffset = CGPointMake(ox, oy);
			originalSize = CGSizeMake(ow, oh);
		} else if(format == 1 || format == 2) {
			CGRect frame = CCRectFromString([frameDict objectForKey:@"frame"]);
			BOOL rotated = NO;

			// rotation
			if(format == 2)
				rotated = [[frameDict objectForKey:@"rotated"] boolValue];

			CGPoint offset = CCPointFromString([frameDict objectForKey:@"offset"]);
			CGSize sourceSize = CCSizeFromString([frameDict objectForKey:@"sourceSize"]);

			// set frame info
			rectInPixels = frame;
			isRotated = rotated;
			frameOffset = offset;
			originalSize = sourceSize;
		} else if(format == 3) {
			// get values
			CGSize spriteSize = CCSizeFromString([frameDict objectForKey:@"spriteSize"]);
			CGPoint spriteOffset = CCPointFromString([frameDict objectForKey:@"spriteOffset"]);
			CGSize spriteSourceSize = CCSizeFromString([frameDict objectForKey:@"spriteSourceSize"]);
			CGRect textureRect = CCRectFromString([frameDict objectForKey:@"textureRect"]);
			BOOL textureRotated = [[frameDict objectForKey:@"textureRotated"] boolValue];

			// get aliases
			NSArray *aliases = [frameDict objectForKey:@"aliases"];
			for(NSString *alias in aliases) {
				if( [_spriteFramesAliases objectForKey:alias] )
					CCLOGWARN(@"cocos2d: WARNING: an alias with name %@ already exists",alias);

				[_spriteFramesAliases setObject:frameDictKey forKey:alias];
			}

			// set frame info
			rectInPixels = CGRectMake(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height);
			isRotated = textureRotated;
			frameOffset = spriteOffset;
			originalSize = spriteSourceSize;
		}

		NSString *textureFileName = nil;
		CCTexture * texture = nil;

		if ( [textureReference isKindOfClass:[NSString class]] )
		{
			textureFileName	= textureReference;
		}
        else if ( [textureReference isKindOfClass:[CCTexture class]] )
		{
			texture = textureReference;
		}

		if ( textureFileName )
		{
			spriteFrame = [[CCSpriteFrame alloc] initWithTextureFilename:textureFileName rectInPixels:rectInPixels rotated:isRotated trimOffsetInPixels:frameOffset untrimmedSizeInPixels:originalSize];
		}
		else
		{
			spriteFrame = [[CCSpriteFrame alloc] initWithTexture:texture rectInPixels:rectInPixels rotated:isRotated trimOffsetInPixels:frameOffset untrimmedSizeInPixels:originalSize];
		}

		// add sprite frame
		[_spriteFrames setObject:spriteFrame forKey:frameDictKey];
        
        // Add an alias that allows spriteframe files to be treated as directories.
        // Ex: A frame named "bar.png" in a spritesheet named "bar.plist" will add both "bar.png" and "foo/bar.png" to the dictionary.
        if(pathPrefix && ![frameDictKey hasPrefix:pathPrefix]){
            NSString *key = [pathPrefix stringByAppendingPathComponent:frameDictKey];
            _spriteFrames[key] = spriteFrame;
        }
	}
}

-(void) addSpriteFramesWithFile:(NSString*)plistFile textureReference:(id)textureReference
{
	NSAssert(textureReference, @"textureReference should not be nil");
	NSAssert(plistFile, @"plist filename should not be nil");
	
	if( ! [_loadedFilenames member:plistFile] ) {
        NSError *err = nil;
        
        CCFile *file = [[CCFileLocator sharedFileLocator] fileNamed:plistFile error:&err];
        NSAssert(err == nil, @"Error finding %@: %@", plistFile, err);
        
        NSDictionary *dict = [file loadPlist:&err];
        NSAssert(err == nil, @"Error loading %@: %@", plistFile, err);

		[self addSpriteFramesWithDictionary:dict textureReference:textureReference prefix:[plistFile stringByDeletingPathExtension]];
		
		[_loadedFilenames addObject:plistFile];
	}
	else
		CCLOGINFO(@"cocos2d: CCSpriteFrameCache: file already loaded: %@", plist);
}

-(void) addSpriteFramesWithFile:(NSString*)plist textureFilename:(NSString*)textureFilename
{
	return [self addSpriteFramesWithFile:plist textureReference:textureFilename];
}

-(void) addSpriteFramesWithFile:(NSString*)plist texture:(CCTexture*)texture
{
	return [self addSpriteFramesWithFile:plist textureReference:texture];
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

		NSString *texturePath = nil;
		NSDictionary *metadataDict = [dict objectForKey:@"metadata"];
		if( metadataDict )
			// try to read  texture file name from meta data
			texturePath = [metadataDict objectForKey:@"textureFileName"];


		if( texturePath )
		{
			// build texture path relative to plist file
			NSString *textureBase = [plistFile stringByDeletingLastPathComponent];
			texturePath = [textureBase stringByAppendingPathComponent:texturePath];
		} else {
			// build texture path by replacing file extension
			texturePath = [plistFile stringByDeletingPathExtension];
			texturePath = [texturePath stringByAppendingPathExtension:@"png"];

			CCLOG(@"cocos2d: CCSpriteFrameCache: Trying to use file '%@' as texture", texturePath);
		}

		[self addSpriteFramesWithDictionary:dict textureReference:texturePath prefix:[plistFile stringByDeletingPathExtension]];
		
		[_loadedFilenames addObject:plistFile];
	}
	else 
		CCLOGINFO(@"cocos2d: CCSpriteFrameCache: file already loaded: %@", plist);

}

-(void) addSpriteFrame:(CCSpriteFrame*)frame name:(NSString*)frameName
{
	[_spriteFrames setObject:frame forKey:frameName];
}

#pragma mark CCSpriteFrameCache - removing

-(void) removeSpriteFrames
{
	[_spriteFrames removeAllObjects];
	[_spriteFramesAliases removeAllObjects];
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
	if( ! name )
		return;

	// Is this an alias ?
	NSString *key = [_spriteFramesAliases objectForKey:name];

	if( key ) {
		[_spriteFrames removeObjectForKey:key];
		[_spriteFramesAliases removeObjectForKey:name];

	} else
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
    
    // Last, try the alias dictionary.
    // These are provided by format #3 when loading the sprite frame files.
    // I have no idea what format #3 is other than there is code for it above...
	if(frame == nil){
		NSString *key = _spriteFramesAliases[name];
		frame = _spriteFrames[key];
	}

	return (CCSpriteFrame *)frame.proxy;
}

@end
