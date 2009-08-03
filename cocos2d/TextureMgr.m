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
#import "Director.h"
#import "Support/FileUtils.h"
#import "Support/Texture2D.h"

static EAGLContext *auxEAGLcontext = nil;

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
- (void) dealloc
{
	CCLOG(@"deallocing %@", self);
	[target_ release];
	[data_ release];
	[super dealloc];
}

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
	if( (self=[super init]) ) {
		textures = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
		dictLock = [[NSLock alloc] init];
		contextLock = [[NSLock alloc] init];
	}

	return self;
}

-(void) dealloc
{
	CCLOG( @"deallocing %@", self);

	[textures release];
	[dictLock release];
	[contextLock release];
	[auxEAGLcontext release];
	auxEAGLcontext = nil;
	sharedTextureMgr = nil;
	[super dealloc];
}

#pragma mark TextureMgr - Add Images

-(void) addImageWithAsyncObject:(AsyncObject*)async
{
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	// textures will be created on the main OpenGL context
	// it seems that in SDK 2.2.x there can't be 2 threads creating textures at the same time
	// the lock is used for this purpose: issue #472
	[contextLock lock];
	if( auxEAGLcontext == nil ) {
		auxEAGLcontext = [[EAGLContext alloc]
							   initWithAPI:kEAGLRenderingAPIOpenGLES1
							   sharegroup:[[[[Director sharedDirector] openGLView] context] sharegroup]];
		
		if( ! auxEAGLcontext )
			CCLOG(@"TextureMgr: Could not create EAGL context");
	}
	
	if( [EAGLContext setCurrentContext:auxEAGLcontext] ) {

		// load / create the texture
		Texture2D *tex = [self addImage:async.data];

		// The callback will be executed on the main thread
		[async.target performSelectorOnMainThread:async.selector withObject:tex waitUntilDone:NO];
		
		[EAGLContext setCurrentContext:nil];
	} else {
		CCLOG(@"TetureMgr: EAGLContext error");
	}
	[contextLock unlock];
	
	[autoreleasepool release];
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

	// schedule the load
	
	AsyncObject *asyncObject = [[AsyncObject alloc] init];
	asyncObject.selector = selector;
	asyncObject.target = target;
	asyncObject.data = filename;
	
	[NSThread detachNewThreadSelector:@selector(addImageWithAsyncObject:) toTarget:self withObject:asyncObject];
	[asyncObject release];
}

-(Texture2D*) addImage: (NSString*) path
{
	NSAssert(path != nil, @"TextureMgr: fileimage MUST not be nill");

	Texture2D * tex = nil;

	// MUTEX:
	// Needed since addImageAsync calls this method from a different thread
	[dictLock lock];
	
	tex=[textures objectForKey: path];
	
	if( ! tex ) {
		
		// Split up directory and filename
		NSString *fullpath = [FileUtils fullPathFromRelativePath: path ];

		// all images are handled by UIImage except PVR extension that is handled by our own handler
		if ( [[path lowercaseString] hasSuffix:@".pvr"] )
			tex = [self addPVRTCImage:fullpath];
		else {
		
			tex = [ [Texture2D alloc] initWithImage: [UIImage imageWithContentsOfFile: fullpath ] ];

			[textures setObject: tex forKey:path];
			
			[tex release];
		}
	}
	
	[dictLock unlock];
	
	return tex;
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
	
	NSString *key = [NSString stringWithFormat:@"%08X",(unsigned long)image];
	
	return [self addCGImage: image forKey: key];
}

-(Texture2D*) addCGImage: (CGImageRef) image forKey: (NSString *)key
{
	NSAssert(image != nil, @"TextureMgr: image MUST not be nill");
	
	Texture2D * tex;
	
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
