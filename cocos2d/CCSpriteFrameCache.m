/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Jason Booth
 *
 * Copyright (c) 2009 Robert J Payne
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
 *
 */

/*
 * To create sprite frames and texture atlas, use this tool:
 * http://zwoptex.zwopple.com/
 */

#import "Platforms/CCNS.h"
#import "ccMacros.h"
#import "CCTextureCache.h"
#import "CCSpriteFrameCache.h"
#import "CCSpriteFrame.h"
#import "CCSprite.h"
#import "Support/CCFileUtils.h"


@implementation CCSpriteFrameCache

#pragma mark CCSpriteFrameCache - Alloc, Init & Dealloc

static CCSpriteFrameCache *sharedSpriteFrameCache_=nil;

+ (CCSpriteFrameCache *)sharedSpriteFrameCache
{
	if (!sharedSpriteFrameCache_)
		sharedSpriteFrameCache_ = [[CCSpriteFrameCache alloc] init];

	return sharedSpriteFrameCache_;
}

+(id)alloc
{
	NSAssert(sharedSpriteFrameCache_ == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedSpriteFrameCache
{
	[sharedSpriteFrameCache_ release];
	sharedSpriteFrameCache_ = nil;
}

-(id) init
{
	if( (self=[super init]) ) {
		spriteFrames_ = [[NSMutableDictionary alloc] initWithCapacity: 100];
		spriteFramesAliases_ = [[NSMutableDictionary alloc] initWithCapacity:10];
	}

	return self;
}

- (NSString*) description
{
#ifdef __LP64__
	return [NSString stringWithFormat:@"<%@ = %p | num of sprite frames =  %lu>", [self class], self, [spriteFrames_ count]];
#else
	return [NSString stringWithFormat:@"<%@ = %p | num of sprite frames =  %u>", [self class], self, [spriteFrames_ count]];
#endif
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	[spriteFrames_ release];
	[spriteFramesAliases_ release];
	[super dealloc];
}

#pragma mark CCSpriteFrameCache - loading sprite frames

-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary texture:(CCTexture2D*)texture
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
	NSAssert( format >= 0 && format <= 3, @"cocos2d: WARNING: format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:texture:");


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
				CCLOG(@"cocos2d: WARNING: originalWidth/Height not found on the CCSpriteFrame. AnchorPoint won't work as expected. Regenerate the .plist");

			// abs ow/oh
			ow = abs(ow);
			oh = abs(oh);
			// create frame

			spriteFrame = [[CCSpriteFrame alloc] initWithTexture:texture
													rectInPixels:CGRectMake(x, y, w, h)
														 rotated:NO
														  offset:CGPointMake(ox, oy)
													originalSize:CGSizeMake(ow, oh)];
		} else if(format == 1 || format == 2) {
			CGRect frame = CCRectFromString([frameDict objectForKey:@"frame"]);
			BOOL rotated = NO;

			// rotation
			if(format == 2)
				rotated = [[frameDict objectForKey:@"rotated"] boolValue];

			CGPoint offset = CCPointFromString([frameDict objectForKey:@"offset"]);
			CGSize sourceSize = CCSizeFromString([frameDict objectForKey:@"sourceSize"]);

			// create frame
			spriteFrame = [[CCSpriteFrame alloc] initWithTexture:texture
													rectInPixels:frame
														 rotated:rotated
														  offset:offset
													originalSize:sourceSize];
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
				if( [spriteFramesAliases_ objectForKey:alias] )
					CCLOG(@"cocos2d: WARNING: an alias with name %@ already exists",alias);

				[spriteFramesAliases_ setObject:frameDictKey forKey:alias];
			}

			// create frame
			spriteFrame = [[CCSpriteFrame alloc] initWithTexture:texture
													rectInPixels:CGRectMake(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height)
														 rotated:textureRotated
														  offset:spriteOffset
													originalSize:spriteSourceSize];
		}

		// add sprite frame
		[spriteFrames_ setObject:spriteFrame forKey:frameDictKey];
		[spriteFrame release];
	}
}

-(void) addSpriteFramesWithFile:(NSString*)plist texture:(CCTexture2D*)texture
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

	[self addSpriteFramesWithDictionary:dict texture:texture];
}

-(void) addSpriteFramesWithFile:(NSString*)plist textureFile:(NSString*)textureFileName
{
	NSAssert( textureFileName, @"Invalid texture file name");
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:textureFileName];

	if( texture )
		[self addSpriteFramesWithFile:plist texture:texture];
	else
		CCLOG(@"cocos2d: CCSpriteFrameCache: couldn't load texture file. File not found: %@", textureFileName);
}

-(void) addSpriteFramesWithFile:(NSString*)plist
{
    NSString *path = [CCFileUtils fullPathFromRelativePath:plist];
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

    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:texturePath];

	if( texture )
		[self addSpriteFramesWithDictionary:dict texture:texture];

	else
		CCLOG(@"cocos2d: CCSpriteFrameCache: Couldn't load texture");
}

-(void) addSpriteFrame:(CCSpriteFrame*)frame name:(NSString*)frameName
{
	[spriteFrames_ setObject:frame forKey:frameName];
}

#pragma mark CCSpriteFrameCache - removing

-(void) removeSpriteFrames
{
	[spriteFrames_ removeAllObjects];
	[spriteFramesAliases_ removeAllObjects];
}

-(void) removeUnusedSpriteFrames
{
	NSArray *keys = [spriteFrames_ allKeys];
	for( id key in keys ) {
		id value = [spriteFrames_ objectForKey:key];
		if( [value retainCount] == 1 ) {
			CCLOG(@"cocos2d: CCSpriteFrameCache: removing unused frame: %@", key);
			[spriteFrames_ removeObjectForKey:key];
		}
	}
}

-(void) removeSpriteFrameByName:(NSString*)name
{
	// explicit nil handling
	if( ! name )
		return;

	// Is this an alias ?
	NSString *key = [spriteFramesAliases_ objectForKey:name];

	if( key ) {
		[spriteFrames_ removeObjectForKey:key];
		[spriteFramesAliases_ removeObjectForKey:name];

	} else
		[spriteFrames_ removeObjectForKey:name];
}

- (void) removeSpriteFramesFromFile:(NSString*) plist
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

	[self removeSpriteFramesFromDictionary:dict];
}

- (void) removeSpriteFramesFromDictionary:(NSDictionary*) dictionary
{
	NSDictionary *framesDict = [dictionary objectForKey:@"frames"];
	NSMutableArray *keysToRemove=[NSMutableArray array];

	for(NSString *frameDictKey in framesDict)
	{
		if ([spriteFrames_ objectForKey:frameDictKey]!=nil)
			[keysToRemove addObject:frameDictKey];
	}
	[spriteFrames_ removeObjectsForKeys:keysToRemove];
}

- (void) removeSpriteFramesFromTexture:(CCTexture2D*) texture
{
	NSMutableArray *keysToRemove=[NSMutableArray array];

	for (NSString *spriteFrameKey in spriteFrames_)
	{
		if ([[spriteFrames_ valueForKey:spriteFrameKey] texture] == texture)
			[keysToRemove addObject:spriteFrameKey];

	}
	[spriteFrames_ removeObjectsForKeys:keysToRemove];
}

#pragma mark CCSpriteFrameCache - getting

-(CCSpriteFrame*) spriteFrameByName:(NSString*)name
{
	CCSpriteFrame *frame = [spriteFrames_ objectForKey:name];
	if( ! frame ) {
		// try alias dictionary
		NSString *key = [spriteFramesAliases_ objectForKey:name];
		frame = [spriteFrames_ objectForKey:key];

		if( ! frame )
			CCLOG(@"cocos2d: CCSpriteFrameCache: Frame '%@' not found", name);
	}

	return frame;
}

@end
