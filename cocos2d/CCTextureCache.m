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

#import "CCTextureCache.h"
#import "ccMacros.h"
#import "CCDirector.h"
#import "CCTexture2D.h"
#import "Support/CCFileUtils.h"

static EAGLContext *auxEAGLcontext = nil;

@interface CCAsyncObject : NSObject
{
	SEL			selector_;
	id			target_;
	id			data_;
}
@property	(readwrite,assign)	SEL			selector;
@property	(readwrite,retain)	id			target;
@property	(readwrite,retain)	id			data;
@end

@implementation CCAsyncObject
@synthesize selector = selector_;
@synthesize target = target_;
@synthesize data = data_;
- (void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	[target_ release];
	[data_ release];
	[super dealloc];
}
@end



@implementation CCTextureCache

#pragma mark TextureCache - Alloc, Init & Dealloc
static CCTextureCache *sharedTextureCache;

+ (CCTextureCache *)sharedTextureCache
{
	if (!sharedTextureCache)
		sharedTextureCache = [[CCTextureCache alloc] init];
		
	return sharedTextureCache;
}

+(id)alloc
{
	NSAssert(sharedTextureCache == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedTextureCache
{
	[sharedTextureCache release];
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

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | num of textures =  %i>", [self class], self, [textures count]];
}

-(void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);

	[textures release];
	[dictLock release];
	[contextLock release];
	[auxEAGLcontext release];
	auxEAGLcontext = nil;
	sharedTextureCache = nil;
	[super dealloc];
}

#pragma mark TextureCache - Add Images

-(void) addImageWithAsyncObject:(CCAsyncObject*)async
{
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	// textures will be created on the main OpenGL context
	// it seems that in SDK 2.2.x there can't be 2 threads creating textures at the same time
	// the lock is used for this purpose: issue #472
	[contextLock lock];
	if( auxEAGLcontext == nil ) {
		auxEAGLcontext = [[EAGLContext alloc]
							   initWithAPI:kEAGLRenderingAPIOpenGLES1
							   sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]];
		
		if( ! auxEAGLcontext )
			CCLOG(@"cocos2d: TextureCache: Could not create EAGL context");
	}
	
	if( [EAGLContext setCurrentContext:auxEAGLcontext] ) {

		// load / create the texture
		CCTexture2D *tex = [self addImage:async.data];

		// The callback will be executed on the main thread
		[async.target performSelectorOnMainThread:async.selector withObject:tex waitUntilDone:NO];
		
		[EAGLContext setCurrentContext:nil];
	} else {
		CCLOG(@"cocos2d: TetureCache: EAGLContext error");
	}
	[contextLock unlock];
	
	[autoreleasepool release];
}

-(void) addImageAsync: (NSString*) filename target:(id)target selector:(SEL)selector
{
	NSAssert(filename != nil, @"TextureCache: fileimage MUST not be nill");

	// optimization
	
	CCTexture2D * tex;
	
	if( (tex=[textures objectForKey: filename] ) ) {
		[target performSelector:selector withObject:tex];
		return;
	}

	// schedule the load
	
	CCAsyncObject *asyncObject = [[CCAsyncObject alloc] init];
	asyncObject.selector = selector;
	asyncObject.target = target;
	asyncObject.data = filename;
	
	[NSThread detachNewThreadSelector:@selector(addImageWithAsyncObject:) toTarget:self withObject:asyncObject];
	[asyncObject release];
}

-(CCTexture2D*) addImage: (NSString*) path
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");

	CCTexture2D * tex = nil;

	// MUTEX:
	// Needed since addImageAsync calls this method from a different thread
	[dictLock lock];
	
	tex=[textures objectForKey: path];
	
	if( ! tex ) {
		
		// Split up directory and filename
		NSString *fullpath = [CCFileUtils fullPathFromRelativePath: path ];

		// all images are handled by UIImage except PVR extension that is handled by our own handler
		if ( [[path lowercaseString] hasSuffix:@".pvr"] )
			tex = [self addPVRTCImage:fullpath];
		else {

			// prevents overloading the autorelease pool
			UIImage *image = [ [UIImage alloc] initWithContentsOfFile: fullpath ];
			tex = [ [CCTexture2D alloc] initWithImage: image ];
			[image release];
			

			if( tex )
				[textures setObject: tex forKey:path];
			else
				CCLOG(@"cocos2d: Couldn't add image:%@ in CCTextureCache", path);

			
			[tex release];
		}
	}
	
	[dictLock unlock];
	
	return tex;
}

-(CCTexture2D*) addPVRTCImage: (NSString*) path bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");
	NSAssert( bpp==2 || bpp==4, @"TextureCache: bpp must be either 2 or 4");
	
	CCTexture2D * tex;
	
	if( (tex=[textures objectForKey: path] ) ) {
		return tex;
	}
	
	// Split up directory and filename
	NSString *fullpath = [CCFileUtils fullPathFromRelativePath:path];
	
	NSData *nsdata = [[NSData alloc] initWithContentsOfFile:fullpath];
	tex = [[CCTexture2D alloc] initWithPVRTCData:[nsdata bytes] level:0 bpp:bpp hasAlpha:alpha length:w];
	if( tex )
		[textures setObject: tex forKey:path];
	else
		CCLOG(@"cocos2d: Couldn't add PVRTCImage:%@ in CCTextureCache",path);

	[nsdata release];

	return [tex autorelease];
}

-(CCTexture2D*) addPVRTCImage: (NSString*) fileimage
{
	NSAssert(fileimage != nil, @"TextureCache: fileimage MUST not be nill");

	CCTexture2D * tex;
	
	if( (tex=[textures objectForKey: fileimage] ) ) {
		return tex;
	}
	
	tex = [[CCTexture2D alloc] initWithPVRTCFile: fileimage];
	if( tex )
		[textures setObject: tex forKey:fileimage];
	else
		CCLOG(@"cocos2d: Couldn't add PVRTCImage:%@ in CCTextureCache",fileimage);	
	
	return [tex autorelease];
}

-(CCTexture2D*) addCGImage: (CGImageRef) imageref forKey: (NSString *)key
{
	NSAssert(imageref != nil, @"TextureCache: image MUST not be nill");
	
	CCTexture2D * tex = nil;
	
	// If key is nil, then create a new texture each time
	if( key && (tex=[textures objectForKey: key] ) ) {
		return tex;
	}
	
	// prevents overloading the autorelease pool
	UIImage *image = [[UIImage alloc] initWithCGImage:imageref];
	tex = [[CCTexture2D alloc] initWithImage: image];
	[image release];
	
	if(tex && key)
		[textures setObject: tex forKey:key];
	else
		CCLOG(@"cocos2d: Couldn't add CGImage in CCTextureCache");
	
	return [tex autorelease];
}

#pragma mark TextureCache - Remove

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
			CCLOG(@"cocos2d: removing texture: %@", key);
			[textures removeObjectForKey:key];
		}
	}
}

-(void) removeTexture: (CCTexture2D*) tex
{
	if( ! tex )
		return;
	
	NSArray *keys = [textures allKeysForObject:tex];
	
	for( NSUInteger i = 0; i < [keys count]; i++ )
		[textures removeObjectForKey:[keys objectAtIndex:i]];
}
@end
