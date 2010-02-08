/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Jason Booth
 * Copyright (C) 2009 Robert J Payne
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

/*
 * To create sprite frames and texture atlas, use this tool:
 * http://zwoptex.zwopple.com/
 */

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
}

-(id) init
{
	if( (self=[super init]) ) {
		spriteFrames = [[NSMutableDictionary dictionaryWithCapacity: 100] retain];
	}
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | num of sprite frames =  %i>", [self class], self, [spriteFrames count]];
}

-(void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	
	[spriteFrames release];
	[super dealloc];
}

#pragma mark CCSpriteFrameCache - loading sprite frames

-(void) addSpriteFramesWithDictionary:(NSDictionary*)dictionary texture:(CCTexture2D*)texture
{
	NSDictionary *framesDict = [dictionary objectForKey:@"frames"];
	for(NSString *frameDictKey in framesDict) {
		NSDictionary *frameDict = [framesDict objectForKey:frameDictKey];
		float x = [[frameDict objectForKey:@"x"] floatValue];
		float y = [[frameDict objectForKey:@"y"] floatValue];
		float w = [[frameDict objectForKey:@"width"] floatValue];
		float h = [[frameDict objectForKey:@"height"] floatValue];
		float ox = [[frameDict objectForKey:@"offsetX"] floatValue];
		float oy = [[frameDict objectForKey:@"offsetY"] floatValue];
		int ow = [[frameDict objectForKey:@"originalWidth"] intValue];
		int oh = [[frameDict objectForKey:@"originalHeight"] intValue];

		if( !ow || !oh ) {
			CCLOG(@"cocos2d: WARNING: originalWidth/Height not found on the CCSpriteFrame. AnchorPoint won't work as expected. Regenrate the .plist");
		}
		
		// zwoptex fix
		ow = abs(ow);
		oh = abs(oh);

		CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(x,y,w,h) offset:CGPointMake(ox,oy) originalSize:CGSizeMake(ow,oh)];
		
		[spriteFrames setObject:frame forKey:frameDictKey];
	}
	
}

-(void) addSpriteFramesWithFile:(NSString*)plist texture:(CCTexture2D*)texture
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];

	return [self addSpriteFramesWithDictionary:dict texture:texture];
}

-(void) addSpriteFramesWithFile:(NSString*)plist
{
	NSString *path = [CCFileUtils fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSString *texturePath = [NSString stringWithString:plist];
	texturePath = [texturePath stringByDeletingPathExtension];
	texturePath = [texturePath stringByAppendingPathExtension:@"png"];
	
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:texturePath];
	
	return [self addSpriteFramesWithDictionary:dict texture:texture];
}

-(void) addSpriteFrame:(CCSpriteFrame*)frame name:(NSString*)frameName
{
	[spriteFrames setObject:frame forKey:frameName];
}

#pragma mark CCSpriteFrameCache - removing

-(void) removeSpriteFrames
{
	[spriteFrames removeAllObjects];
}

-(void) removeUnusedSpriteFrames
{
	NSArray *keys = [spriteFrames allKeys];
	for( id key in keys ) {
		id value = [spriteFrames objectForKey:key];		
		if( [value retainCount] == 1 ) {
			CCLOG(@"cocos2d: removing sprite frame: %@", key);
			[spriteFrames removeObjectForKey:key];
		}
	}	
}

-(void) removeSpriteFrameByName:(NSString*)name
{
	[spriteFrames removeObjectForKey:name];
}

#pragma mark CCSpriteFrameCache - getting

-(CCSpriteFrame*) spriteFrameByName:(NSString*)name
{
	return [spriteFrames objectForKey:name];
}

#pragma mark CCSpriteFrameCache - sprite creation

-(CCSprite*) createSpriteWithFrameName:(NSString*)name
{
	CCSpriteFrame *frame = [spriteFrames objectForKey:name];
	return [CCSprite spriteWithSpriteFrame:frame];
}
@end
