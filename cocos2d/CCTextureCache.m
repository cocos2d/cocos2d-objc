/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
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

#import <Availability.h>

#import "Platforms/CCGL.h"
#import "CCTextureCache.h"
#import "CCTexture2D.h"
#import "CCTexturePVR.h"
#import "ccMacros.h"
#import "CCConfiguration.h"
#import "Support/CCFileUtils.h"
#import "CCDirector.h"
#import "ccConfig.h"
#import "ccTypes.h"

// needed for CCCallFuncO in Mac-display_link version
#import "CCActionManager.h"
#import "CCActionInstant.h"

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
static EAGLContext *_auxGLcontext = nil;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
static NSOpenGLContext *_auxGLcontext = nil;
#endif

@implementation CCTextureCache

#pragma mark TextureCache - Alloc, Init & Dealloc
static CCTextureCache *sharedTextureCache;

+ (CCTextureCache *)sharedTextureCache
{
	if (!sharedTextureCache)
		sharedTextureCache = [[self alloc] init];
		
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
	sharedTextureCache = nil;
}

-(id) init
{
	if( (self=[super init]) ) {
		textures_ = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
		
		// init "global" stuff
		_loadingQueue = dispatch_queue_create("org.cocos2d.texturecacheloading", NULL);		
		_dictQueue = dispatch_queue_create("org.cocos2d.texturecachedict", NULL);

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		CC_GLVIEW *view = [[CCDirector sharedDirector] openGLView];
		NSAssert(view, @"Do not initialize the TextureCache before the Director");
		_auxGLcontext = [[EAGLContext alloc]
						 initWithAPI:kEAGLRenderingAPIOpenGLES2
						 sharegroup:[[view context] sharegroup]];
		
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		
		MacGLView *view = [[CCDirector sharedDirector] openGLView];
		NSAssert(view, @"Do not initialize the TextureCache before the Director");

		
		NSOpenGLPixelFormat *pf = [view pixelFormat];
		NSOpenGLContext *share = [view openGLContext];
		
		_auxGLcontext = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:share];

#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

		NSAssert( _auxGLcontext, @"TextureCache: Could not create EAGL context");		

	}

	return self;
}

- (NSString*) description
{
	__block NSString *desc = nil;
	dispatch_sync(_dictQueue, ^{
		desc = [NSString stringWithFormat:@"<%@ = %08X | num of textures =  %i | keys: %@>",
			[self class],
			self,
			[textures_ count],
			[textures_ allKeys]
			];
	});
	return desc;
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);

	dispatch_sync(_dictQueue, ^{
		[textures_ release];
	});
	[_auxGLcontext release];
	_auxGLcontext = nil;
	sharedTextureCache = nil;
	dispatch_release(_loadingQueue);
	dispatch_release(_dictQueue);

	[super dealloc];
}

#pragma mark TextureCache - Add Images

-(void) addImageAsync: (NSString*)path target:(id)target selector:(SEL)selector
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");
	NSAssert(target != nil, @"TextureCache: target can't be nil");
	NSAssert(selector != NULL, @"TextureCache: selector can't be NULL");

	// optimization
	
	__block CCTexture2D * tex;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	path = [CCFileUtils removeSuffixFromFile:path];
#endif
	
	dispatch_sync(_dictQueue, ^{
		tex = [textures_ objectForKey:path];
	});
	
	if(tex) {
		[target performSelector:selector withObject:tex];
		return;
	}

	// dispatch it serially
	dispatch_async(_loadingQueue, ^{
		
		CCTexture2D *texture;
		
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		if( [EAGLContext setCurrentContext:_auxGLcontext] ) {
			
			// load / create the texture
			texture = [self addImage:path];
			
			glFlush();
			
			// callback should be executed in cocos2d thread
			dispatch_async(dispatch_get_main_queue(), ^{
				[target performSelector:selector withObject:texture];
			});
			
			[EAGLContext setCurrentContext:nil];
		} else {
			CCLOG(@"cocos2d: ERROR: TetureCache: Could not set EAGLContext");
		}
		
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		
		[_auxGLcontext makeCurrentContext];
		
		// load / create the texture
		texture = [self addImage:path];
		
		glFlush();
		
		// callback should be executed in cocos2d thread
		dispatch_async(dispatch_get_main_queue(), ^{
			[target performSelector:selector withObject:texture];
		});
		
		[NSOpenGLContext clearCurrentContext];
				
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

	});	
}

-(void) addImageAsync:(NSString*)path withBlock:(void(^)(CCTexture2D *tex))block
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nil");
	
	// optimization
	
	__block CCTexture2D * tex;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	path = [CCFileUtils removeSuffixFromFile:path];
#endif
	
	dispatch_sync(_dictQueue, ^{
		tex = [textures_ objectForKey:path];
	});
	
	if(tex) {
		block(tex);
		return;
	}
	
	// dispatch it serially
	dispatch_async( _loadingQueue, ^{
		
		CCTexture2D *texture;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		if( [EAGLContext setCurrentContext:_auxGLcontext] ) {
			
			// load / create the texture
			texture = [self addImage:path];
			
			glFlush();
			
			// callback should be executed in cocos2d thread
			dispatch_async(dispatch_get_main_queue(), ^{
				block(texture);
			});
			
			[EAGLContext setCurrentContext:nil];
		} else {
			CCLOG(@"cocos2d: ERROR: TetureCache: Could not set EAGLContext");
		}

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		
		[_auxGLcontext makeCurrentContext];
		
		// load / create the texture
		texture = [self addImage:path];
		
		glFlush();
		
		// callback should be executed in cocos2d thread
		dispatch_async(dispatch_get_main_queue(), ^{
			block(texture);
		});
		
		[NSOpenGLContext clearCurrentContext];
		
#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

	});	
}

-(CCTexture2D*) addImage: (NSString*) path
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");

	__block CCTexture2D * tex = nil;

	// remove possible -HD suffix to prevent caching the same image twice (issue #1040)
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	path = [CCFileUtils removeSuffixFromFile: path];
#endif

	dispatch_sync(_dictQueue, ^{
		tex = [textures_ objectForKey: path];
	});
	
	if( ! tex ) {
		
		NSString *lowerCase = [path lowercaseString];
		// all images are handled by UIImage except PVR extension that is handled by our own handler
		
		if ( [lowerCase hasSuffix:@".pvr"] || [lowerCase hasSuffix:@".pvr.gz"] || [lowerCase hasSuffix:@".pvr.ccz"] )
			tex = [self addPVRImage:path];

		// Only iPhone
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

		// Issue #886: TEMPORARY FIX FOR TRANSPARENT JPEGS IN IOS4
		else if ( ( [[CCConfiguration sharedConfiguration] OSVersion] >= kCCiOSVersion_4_0) &&
				  ( [lowerCase hasSuffix:@".jpg"] || [lowerCase hasSuffix:@".jpeg"] ) 
				 ) {
			// convert jpg to png before loading the texture
			
			CCLOG(@"cocos2d: WARNING: Loading JPEG image. For faster loading times, convert it to PVR or PNG");
			
			ccResolutionType resolution;
			NSString *fullpath = [CCFileUtils fullPathFromRelativePath: path resolutionType:&resolution];
						
			UIImage *jpg = [[UIImage alloc] initWithContentsOfFile:fullpath];
			UIImage *png = [[UIImage alloc] initWithData:UIImagePNGRepresentation(jpg)];
			tex = [ [CCTexture2D alloc] initWithImage:png resolutionType:resolution];
			[png release];
			[jpg release];
			
			if( tex ){
				dispatch_sync(_dictQueue, ^{
					[textures_ setObject: tex forKey:path];
				});
			}else{
				CCLOG(@"cocos2d: Couldn't add image:%@ in CCTextureCache", path);
			}
			
			// autorelease prevents possible crash in multithreaded environments
			[tex autorelease];
		}

		else {
			
			ccResolutionType resolution;
			NSString *fullpath = [CCFileUtils fullPathFromRelativePath:path resolutionType:&resolution];

			UIImage *image = [ [UIImage alloc] initWithContentsOfFile: fullpath ];
			tex = [ [CCTexture2D alloc] initWithImage:image resolutionType:resolution];
			[image release];
			
			if( tex ){
				dispatch_sync(_dictQueue, ^{
					[textures_ setObject: tex forKey:path];
				});
			}else{
				CCLOG(@"cocos2d: Couldn't add image:%@ in CCTextureCache", path);
			}
			
			// autorelease prevents possible crash in multithreaded environments
			[tex autorelease];			
		}

		
		// Only in Mac
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		else {
			NSString *fullpath = [CCFileUtils fullPathFromRelativePath: path ];

			NSData *data = [[NSData alloc] initWithContentsOfFile:fullpath];
			NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithData:data];
			tex = [ [CCTexture2D alloc] initWithImage:[image CGImage]];
			
			[data release];
			[image release];

			if( tex ){
				dispatch_sync(_dictQueue, ^{
					[textures_ setObject: tex forKey:path];
				});
			}else{
				CCLOG(@"cocos2d: Couldn't add image:%@ in CCTextureCache", path);
			}
			
			// autorelease prevents possible crash in multithreaded environments
			[tex autorelease];			
		}

#endif // __MAC_OS_X_VERSION_MAX_ALLOWED

	}
	
	return tex;
}


-(CCTexture2D*) addCGImage: (CGImageRef) imageref forKey: (NSString *)key
{
	NSAssert(imageref != nil, @"TextureCache: image MUST not be nill");
	
	__block CCTexture2D * tex = nil;
	
	// If key is nil, then create a new texture each time
	if( key ) {
		dispatch_sync(_dictQueue, ^{
			tex = [textures_ objectForKey:key];
		});
		if(tex)
			return tex;
	}
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	// prevents overloading the autorelease pool
	UIImage *image = [[UIImage alloc] initWithCGImage:imageref];
	tex = [[CCTexture2D alloc] initWithImage:image resolutionType:kCCResolutionUnknown];
	[image release];

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	tex = [[CCTexture2D alloc] initWithImage: imageref];
#endif
	
	if(tex && key){
		dispatch_sync(_dictQueue, ^{
			[textures_ setObject: tex forKey:key];
		});
	}else{
		CCLOG(@"cocos2d: Couldn't add CGImage in CCTextureCache");
	}
	
	return [tex autorelease];
}

#pragma mark TextureCache - Remove

-(void) removeAllTextures
{
	dispatch_sync(_dictQueue, ^{
		[textures_ removeAllObjects];
	});
}

-(void) removeUnusedTextures
{
	dispatch_sync(_dictQueue, ^{
		NSArray *keys = [textures_ allKeys];
		for( id key in keys ) {
			id value = [textures_ objectForKey:key];		
			if( [value retainCount] == 1 ) {
				CCLOG(@"cocos2d: CCTextureCache: removing unused texture: %@", key);
				[textures_ removeObjectForKey:key];
			}
		}
	});
}

-(void) removeTexture: (CCTexture2D*) tex
{
	if( ! tex )
		return;
	
	dispatch_sync(_dictQueue, ^{
		NSArray *keys = [textures_ allKeysForObject:tex];
		
		for( NSUInteger i = 0; i < [keys count]; i++ )
			[textures_ removeObjectForKey:[keys objectAtIndex:i]];
	});
}

-(void) removeTextureForKey:(NSString*)name
{
	if( ! name )
		return;
	
	dispatch_sync(_dictQueue, ^{
		[textures_ removeObjectForKey:name];
	});
}

#pragma mark TextureCache - Get
- (CCTexture2D *)textureForKey:(NSString *)key
{
	__block CCTexture2D *tex = nil;
	
	dispatch_sync(_dictQueue, ^{
		tex = [textures_ objectForKey:key];
	});
	
	return tex;
}

@end


@implementation CCTextureCache (PVRSupport)

-(CCTexture2D*) addPVRImage:(NSString*)path
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");
	
	__block CCTexture2D * tex;
	
	// remove possible -HD suffix to prevent caching the same image twice (issue #1040)
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	path = [CCFileUtils removeSuffixFromFile: path];
#endif
	
	dispatch_sync(_dictQueue, ^{
		tex = [textures_ objectForKey:path];
	});

	if(tex) {
		return tex;
	}
	
	tex = [[CCTexture2D alloc] initWithPVRFile: path];
	if( tex ){
		dispatch_sync(_dictQueue, ^{
			[textures_ setObject: tex forKey:path];
		});
	}else{
		CCLOG(@"cocos2d: Couldn't add PVRImage:%@ in CCTextureCache",path);
	}
	
	return [tex autorelease];
}

@end


@implementation CCTextureCache (Debug)

-(void) dumpCachedTextureInfo
{
	__block NSUInteger count = 0;
	__block NSUInteger totalBytes = 0;
	
	dispatch_sync(_dictQueue, ^{
		for (NSString* texKey in textures_) {
			CCTexture2D* tex = [textures_ objectForKey:texKey];
			NSUInteger bpp = [tex bitsPerPixelForFormat];
			// Each texture takes up width * height * bytesPerPixel bytes.
			NSUInteger bytes = tex.pixelsWide * tex.pixelsHigh * bpp / 8;
			totalBytes += bytes;
			count++;
			NSLog( @"cocos2d: \"%@\"\trc=%lu\tid=%lu\t%lu x %lu\t@ %ld bpp =>\t%lu KB",
				  texKey,
				  (long)[tex retainCount],
				  (long)tex.name,
				  (long)tex.pixelsWide,
				  (long)tex.pixelsHigh,
				  (long)bpp,
				  (long)bytes / 1024 );
		}
	});
	NSLog( @"cocos2d: CCTextureCache dumpDebugInfo:\t%ld textures,\tfor %lu KB (%.2f MB)", (long)count, (long)totalBytes / 1024, totalBytes / (1024.0f*1024.0f));
}

@end
