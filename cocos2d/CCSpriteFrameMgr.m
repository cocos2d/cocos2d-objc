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

#import "ccMacros.h"
#import "CCTextureMgr.h"
#import "CCSpriteFrameMgr.h"
#import "CCSpriteFrame.h"
#import "CCSprite.h"
#import "Support/FileUtils.h"


@implementation CCSpriteFrameMgr

#pragma mark CCSpriteFrameMgr - Alloc, Init & Dealloc

static CCSpriteFrameMgr *sharedSpriteFrameMgr;

+ (CCSpriteFrameMgr *)sharedSpriteFrameMgr
{
	@synchronized([CCSpriteFrameMgr class])
	{
		if (!sharedSpriteFrameMgr)
			sharedSpriteFrameMgr = [[CCSpriteFrameMgr alloc] init];
		
	}
	return sharedSpriteFrameMgr;
}

+(id)alloc
{
	@synchronized([CCSpriteFrameMgr class])
	{
		NSAssert(sharedSpriteFrameMgr == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	// to avoid compiler warning
	return nil;
}

+(void)purgeSharedSpriteFrameMgr
{
	@synchronized( self ) {
		[sharedSpriteFrameMgr release];
	}
}

-(id) init
{
	if( (self=[super init]) ) {
		spriteFrames = [[NSMutableDictionary dictionaryWithCapacity: 100] retain];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	
	[spriteFrames release];
	[super dealloc];
}

#pragma mark CCSpriteFrameMgr - loading sprite frames

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
		
		CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:CGRectMake(x,y,w,h) offset:CGPointMake(ox,oy)];
		
		[spriteFrames setObject:frame forKey:frameDictKey];
	}
	
}

-(void) addSpriteFramesWithFilename:(NSString*)plist texture:(CCTexture2D*)texture
{
}

-(void) addSpriteFramesWithFilename:(NSString*)plist
{
	NSString *path = [FileUtils fullPathFromRelativePath:plist];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSString *texturePath = [NSString stringWithString:plist];
	texturePath = [texturePath stringByDeletingPathExtension];
	texturePath = [texturePath stringByAppendingPathExtension:@"png"];
	
	CCTexture2D *texture = [[CCTextureMgr sharedTextureMgr] addImage:texturePath];
	
	return [self addSpriteFramesWithDictionary:dict texture:texture];
}

#pragma mark CCSpriteFrameMgr - removing

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

#pragma mark CCSpriteFrameMgr - getting

-(CCSpriteFrame*) spriteFrameByName:(NSString*)name
{
	return [spriteFrames objectForKey:name];
}

#pragma mark CCSpriteFrameMgr - sprite creation

-(CCSprite*) createSpriteWithFrameName:(NSString*)name
{
	CCSpriteFrame *frame = [spriteFrames objectForKey:name];
	CCSprite *sprite = [CCSprite spriteWithTexture:frame.texture rect:frame.rect offset:frame.offset];
	return sprite;
}
@end
