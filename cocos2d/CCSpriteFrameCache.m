/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
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
#import "CCSpriteFrameCache.h"
#import "CCSpriteFrame.h"
#import "CCSprite.h"
#import "Support/CCFileUtils.h"
#import "CCTexture_Private.h"


@interface CCSpriteFrame(Proxy)
- (BOOL)hasProxy;
- (CCProxy *)proxy;
@end


@interface CCSpriteFrameCache ()
- (void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary textureFilename:(NSString*)filename;
- (void) addSpriteFramesWithDictionary:(NSDictionary *)dictionary texture:(CCTexture *)texture;
- (void) removeSpriteFramesFromDictionary:(NSDictionary*) dictionary;
@end


@implementation CCSpriteFrameCache

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

-(void) loadSpriteFrameLookupDictionaryFromFile:(NSString*)filename
{
	NSString *fullpath = [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:filename];
	if( fullpath ) {
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullpath];
        
		NSDictionary *metadata = [dict objectForKey:@"metadata"];
		NSInteger version = [[metadata objectForKey:@"version"] integerValue];
		if( version != 1) {
			CCLOG(@"cocos2d: ERROR: Invalid filenameLookup dictionary version: %ld. Filename: %@", (long)version, filename);
			return;
		}
		
		NSArray *spriteFrameFiles = [dict objectForKey:@"spriteFrameFiles"];
		for (NSString* spriteFrameFile in spriteFrameFiles)
        {
            [self registerSpriteFramesFile:spriteFrameFile];
        }
	}
}

- (void)loadSpriteFrameLookupsInAllSearchPathsWithName:(NSString *)filename
{
    NSArray *paths = [[CCFileUtils sharedFileUtils] fullPathsOfFileNameInAllSearchPaths:filename];

    for (NSString *spriteFrameLookupFullPath in paths)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:spriteFrameLookupFullPath];

        NSDictionary *metadata = dict[@"metadata"];
        NSInteger version = [metadata[@"version"] integerValue];
        if (version != 1)
        {
            CCLOG(@"cocos2d: ERROR: Invalid filenameLookup dictionary version: %ld. Filename: %@", (long) version, filename);
            return;
        }

        NSArray *spriteFrameFiles = dict[@"spriteFrameFiles"];
        for (NSString *spriteFrameFile in spriteFrameFiles)
        {
            [self registerSpriteFramesFile:spriteFrameFile];
        }
    }
}

- (void) registerSpriteFramesFile:(NSString*)plist
{
	NSAssert(plist, @"plist filename should not be nil");
    
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:plist];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSDictionary *metadataDict = [dictionary objectForKey:@"metadata"];
	NSDictionary *framesDict = [dictionary objectForKey:@"frames"];
    
	int format = 0;
    
	// get the format
	if(metadataDict != nil)
		format = [[metadataDict objectForKey:@"format"] intValue];
    
	// check the format
	NSAssert( format >= 0 && format <= 3, @"format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:textureFilename:");
    
    for(NSString *frameDictKey in framesDict)
    {
        [_spriteFrameFileLookup setObject:plist forKey:frameDictKey];
    }
}

#pragma mark CCSpriteFrameCache - loading sprite frames

-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary textureReference:(id)textureReference
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
			spriteFrame = [[CCSpriteFrame alloc] initWithTextureFilename:textureFileName rectInPixels:rectInPixels rotated:isRotated offset:frameOffset originalSize:originalSize];
		}
		else
		{
			spriteFrame = [[CCSpriteFrame alloc] initWithTexture:texture rectInPixels:rectInPixels rotated:isRotated offset:frameOffset originalSize:originalSize];
		}

		// add sprite frame
		[_spriteFrames setObject:spriteFrame forKey:frameDictKey];
	}
}

-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary textureFilename:(NSString*)textureFilename
{
	return [self addSpriteFramesWithDictionary:dictionary textureReference:textureFilename];
}

-(void) addSpriteFramesWithDictionary:(NSDictionary *)dictionary texture:(CCTexture *)texture
{
	return [self addSpriteFramesWithDictionary:dictionary textureReference:texture];
}

-(void) addSpriteFramesWithFile:(NSString*)plist textureReference:(id)textureReference
{
	NSAssert(textureReference, @"textureReference should not be nil");
	NSAssert(plist, @"plist filename should not be nil");
	
	if( ! [_loadedFilenames member:plist] ) {

		NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:plist];
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

		[self addSpriteFramesWithDictionary:dict textureReference:textureReference];
		
		[_loadedFilenames addObject:plist];
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


-(void) addSpriteFramesWithFile:(NSString*)plist
{
	NSAssert(plist, @"plist filename should not be nil");
	
	if( ! [_loadedFilenames member:plist] ) {

		NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:plist];
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

		NSString *texturePath = nil;
		NSDictionary *metadataDict = [dict objectForKey:@"metadata"];
		if( metadataDict )
			// try to read  texture file name from meta data
			texturePath = [metadataDict objectForKey:@"textureFileName"];


		if( texturePath )
		{
			// build texture path relative to plist file
			NSString *textureBase = [plist stringByDeletingLastPathComponent];
			texturePath = [textureBase stringByAppendingPathComponent:texturePath];
		} else {
			// build texture path by replacing file extension
			texturePath = [plist stringByDeletingPathExtension];
			texturePath = [texturePath stringByAppendingPathExtension:@"png"];

			CCLOG(@"cocos2d: CCSpriteFrameCache: Trying to use file '%@' as texture", texturePath);
		}

		[self addSpriteFramesWithDictionary:dict textureFilename:texturePath];
		
		[_loadedFilenames addObject:plist];
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

- (void) removeSpriteFramesFromFile:(NSString*) plist
{
	NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

	[self removeSpriteFramesFromDictionary:dict];
	
	// remove it from the cache
	id ret = [_loadedFilenames member:plist];
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

-(CCSpriteFrame*) spriteFrameByName:(NSString*)name
{
	CCSpriteFrame *frame = [_spriteFrames objectForKey:name];
    
    if (!frame)
    {
        // Check fileLookup.plist
        NSString *newName = [[CCFileUtils sharedFileUtils].filenameLookup objectForKey:name];
        name = newName ?: name;
        
        // Try finding the frame in one of the registered sprite sheets
        NSString* spriteFrameFile = [_spriteFrameFileLookup objectForKey:name];
        if (spriteFrameFile) [self addSpriteFramesWithFile:spriteFrameFile];
        
        // Attempt to load the frame again
        frame = [_spriteFrames objectForKey:name];
    }
    
	if( ! frame ) {
		// try alias dictionary
		NSString *key = [_spriteFramesAliases objectForKey:name];
		frame = [_spriteFrames objectForKey:key];
	}

	return (CCSpriteFrame *)frame.proxy;
}

@end
