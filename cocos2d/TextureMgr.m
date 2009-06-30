/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "TextureMgr.h"
#import "ccMacros.h"
#import "Support/FileUtils.h"
#import "Support/Texture2D.h"

@interface AsyncObject : NSObject
{
	SEL			selector_;
	id			target_;
	id			data_;
}
@property	(readwrite,assign)	SEL			selector;
@property	(readwrite,retain)	id			target;
@property	(readwrite,retain)	id			data;
@end

@implementation AsyncObject
@synthesize selector = selector_;
@synthesize target = target_;
@synthesize data = data_;
@end



@implementation TextureMgr

#pragma mark TextureMgr - Alloc, Init & Dealloc
static TextureMgr *sharedTextureMgr;

+ (TextureMgr *)sharedTextureMgr
{
	@synchronized([TextureMgr class])
	{
		if (!sharedTextureMgr)
			[[TextureMgr alloc] init];
		
		return sharedTextureMgr;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([TextureMgr class])
	{
		NSAssert(sharedTextureMgr == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedTextureMgr = [super alloc];
		return sharedTextureMgr;
	}
	// to avoid compiler warning
	return nil;
}

-(id) init
{
	if( (self=[super init]) )
		textures = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];

	return self;
}

-(void) dealloc
{
	[textures release];
	[super dealloc];
}

#pragma mark TextureMgr - Add Images

-(void) addImageWithAsyncObject:(AsyncObject*)async
{
	Texture2D *tex = [self addImage:async.data];
	[async.target performSelector:async.selector withObject:tex];
}

-(void) addImageAsync: (NSString*) filename target:(id)target selector:(SEL)selector
{
	NSAssert(filename != nil, @"TextureMgr: fileimage MUST not be nill");

	// optimization
	
	Texture2D * tex;
	
	if( (tex=[textures objectForKey: filename] ) ) {
		[target performSelector:selector withObject:tex];
		return;
	}
	
	[NSThread 
	// schedule the load
	
	AsyncObject *asyncObject = [[AsyncObject alloc] init];
	asyncObject.selector = selector;
	asyncObject.target = target;
	asyncObject.data = filename;
	[self performSelectorOnMainThread:@selector(addImageWithAsyncObject:) withObject:asyncObject waitUntilDone:NO];
	
	[asyncObject release];
}

-(Texture2D*) addImage: (NSString*) path
{
	NSAssert(path != nil, @"TextureMgr: fileimage MUST not be nill");

	Texture2D * tex;
	
	if( (tex=[textures objectForKey: path] ) ) {
		return tex;
	}
		
	// Split up directory and filename
	NSString *fullpath = [FileUtils fullPathFromRelativePath: path ];

	// all images are handled by UIImage except PVR extension that is handled by our own handler
	if ( [[path lowercaseString] hasSuffix:@".pvr"] )
		return [self addPVRTCImage:fullpath];
	
	tex = [ [Texture2D alloc] initWithImage: [UIImage imageWithContentsOfFile: fullpath ] ];

	[textures setObject: tex forKey:path];
	
	return [tex autorelease];
}

-(Texture2D*) addPVRTCImage: (NSString*) path bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	NSAssert(path != nil, @"TextureMgr: fileimage MUST not be nill");
	NSAssert( bpp==2 || bpp==4, @"TextureMgr: bpp must be either 2 or 4");
	
	Texture2D * tex;
	
	if( (tex=[textures objectForKey: path] ) ) {
		return tex;
	}
	
	// Split up directory and filename
	NSString *fullpath = [FileUtils fullPathFromRelativePath:path];
	
	NSData *nsdata = [[NSData alloc] initWithContentsOfFile:fullpath];
	tex = [[Texture2D alloc] initWithPVRTCData:[nsdata bytes] level:0 bpp:bpp hasAlpha:alpha length:w];
	[textures setObject: tex forKey:path];
	[nsdata release];

	return [tex autorelease];
}

-(Texture2D*) addPVRTCImage: (NSString*) fileimage
{
	NSAssert(fileimage != nil, @"TextureMgr: fileimage MUST not be nill");

	Texture2D * tex;
	
	if( (tex=[textures objectForKey: fileimage] ) ) {
		return tex;
	}
	
	tex = [[Texture2D alloc] initWithPVRTCFile: fileimage];
	if( tex )
		[textures setObject: tex forKey:fileimage];
	
	return [tex autorelease];
}


-(Texture2D*) addCGImage: (CGImageRef) image
{
	NSAssert(image != nil, @"TextureMgr: image MUST not be nill");
	
	Texture2D * tex;
	NSString *key = [NSString stringWithFormat:@"%08X",(unsigned long)image];
	
	if( (tex=[textures objectForKey: key] ) ) {
		return tex;
	}
	
	tex = [[Texture2D alloc] initWithImage: [UIImage imageWithCGImage:image]];
	[textures setObject: tex forKey:key];
	
	return [tex autorelease];
}

#pragma mark TextureMgr - Cache

-(void) removeAllTextures
{
	[textures removeAllObjects];
}

-(void) removeUnusedTextures
{
	NSArray *keys = [textures allKeys];
	for( id key in keys ) {
		id value = [textures objectForKey:key];		
		if( [value retainCount] == 1 ) {
			CCLOG(@"removing texture: %@", key);
			[textures removeObjectForKey:key];
		}
	}
}

-(void) removeTexture: (Texture2D*) tex
{
	if( ! tex )
		return;
	
	NSArray *keys = [textures allKeysForObject:tex];
	
	for( NSUInteger i = 0; i < [keys count]; i++ )
		[textures removeObjectForKey:[keys objectAtIndex:i]];
}
@end
