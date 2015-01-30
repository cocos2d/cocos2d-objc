/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
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

#import <objc/message.h>

#import "ccMacros.h"

#import "CCTextureCache.h"

#import "Platforms/CCGL.h"
#import "CCTexture_Private.h"
#import "CCDeviceInfo.h"
#import "CCDirector.h"
#import "CCFileUtils.h"
#import "CCFile_Private.h"
#import "CCImage.h"

#if __CC_PLATFORM_IOS
static EAGLContext *_auxGLcontext = nil;
#elif __CC_PLATFORM_MAC
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
	sharedTextureCache = nil;
}

-(id) init
{
	if( (self=[super init]) ) {
		_textures = [NSMutableDictionary dictionaryWithCapacity: 10];
		
		// init "global" stuff
		_loadingQueue = dispatch_queue_create("org.cocos2d.texturecacheloading", NULL);
		_dictQueue = dispatch_queue_create("org.cocos2d.texturecachedict", NULL);
		
		// Skip the GL context sharegroup code for Metal.
		if([CCDeviceInfo sharedDeviceInfo].graphicsAPI == CCGraphicsAPIMetal) return self;

        NSAssert([CCDirector currentDirector], @"Do not initialize the TextureCache before the director is created and set");
        CC_VIEW<CCView> *view;
#if __CC_PLATFORM_IOS
		view = (CCViewiOSGL*)[[CCDirector currentDirector] view];
#elif __CC_PLATFORM_MAC
        view = (CCViewMacGL*)[[CCDirector currentDirector] view];
#elif __CC_PLATFORM_ANDROID
        view = (CCGLView*)[[CCDirector currentDirector] view];
#endif
        NSAssert(view, @"Unable to access view from current CCDirector");

#if __CC_PLATFORM_IOS
		_auxGLcontext = [[EAGLContext alloc]
						 initWithAPI:kEAGLRenderingAPIOpenGLES2
						 sharegroup:[[(CCViewiOSGL *)view context] sharegroup]];

#elif __CC_PLATFORM_MAC
		NSOpenGLPixelFormat *pf = [view pixelFormat];
		NSOpenGLContext *share = [view openGLContext];

		_auxGLcontext = [[NSOpenGLContext alloc] initWithFormat:pf shareContext:share];

#endif // __CC_PLATFORM_MAC

#if !__CC_PLATFORM_ANDROID
		NSAssert( _auxGLcontext, @"TextureCache: Could not create EAGL context");
#endif

	}

	return self;
}

- (NSString*) description
{
	__block NSString *desc = nil;
	dispatch_sync(_dictQueue, ^{
		desc = [NSString stringWithFormat:@"<%@ = %p | num of textures =  %lu | keys: %@>",
			[self class],
			self,
			(unsigned long)[_textures count],
			[_textures allKeys]
			];
	});
	return desc;
}

-(void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
    
#if !__CC_PLATFORM_ANDROID
	_auxGLcontext = nil;
#endif
	sharedTextureCache = nil;
    
	// dispatch_release(_loadingQueue);
	// dispatch_release(_dictQueue);
    
}

#pragma mark TextureCache - Add Images

-(void) addImageAsync: (NSString*)path target:(id)target selector:(SEL)selector
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");
	NSAssert(target != nil, @"TextureCache: target can't be nil");
	NSAssert(selector != NULL, @"TextureCache: selector can't be NULL");

	// remove possible -HD suffix to prevent caching the same image twice (issue #1040)
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	path = [fileUtils standarizePath:path];

	// optimization
	__block CCTexture * tex;
		
	dispatch_sync(_dictQueue, ^{
		tex = [_textures objectForKey:path];
	});

	if(tex) {
		typedef void (*Func)(id, SEL, id);
		((Func)objc_msgSend)(target, selector, tex);
		return;
	}

	// dispatch it serially
	dispatch_async(_loadingQueue, ^{

		CCTexture *texture;

#if __CC_PLATFORM_IOS
		if( [EAGLContext setCurrentContext:_auxGLcontext] ) {

			// load / create the texture
			texture = [self addImage:path];

			glFlush();

			// callback should be executed in cocos2d thread
			[target performSelector:selector onThread:[[CCDirector currentDirector] runningThread] withObject:texture waitUntilDone:NO];

			[EAGLContext setCurrentContext:nil];
		} else {
			CCLOG(@"cocos2d: ERROR: TetureCache: Could not set EAGLContext");
		}

#elif __CC_PLATFORM_MAC

		[_auxGLcontext makeCurrentContext];

		// load / create the texture
		texture = [self addImage:path];

		glFlush();

		// callback should be executed in cocos2d thread
		[target performSelector:selector onThread:[[CCDirector currentDirector] runningThread] withObject:texture waitUntilDone:NO];

		[NSOpenGLContext clearCurrentContext];

#endif // __CC_PLATFORM_MAC

	});
}

-(CCTexture*) addImage: (NSString*) path
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nil");

	// remove possible -HD suffix to prevent caching the same image twice (issue #1040)
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	path = [fileUtils standarizePath:path];

	__block CCTexture * tex = nil;

	dispatch_sync(_dictQueue, ^{
		tex = [_textures objectForKey: path];
	});

	if( ! tex ) {
        CCFile *file = [CCFileUtils fileNamed:path];
        
		if( ! file ) {
			CCLOG(@"cocos2d: Couldn't find file:%@", path);
			return nil;
		}

		NSString *lowerCase = [file.absoluteFilePath lowercaseString];

		// all images are handled by UIKit/AppKit except PVR extension that is handled by cocos2d's handler

        if([lowerCase hasSuffix:@".pvr"] || [lowerCase hasSuffix:@".pvr.gz"] || [lowerCase hasSuffix:@".pvr.ccz"]){
            tex = [self addPVRImage:path];
        } else {
            CCImage *image = [[CCImage alloc] initWithCCFile:file options:nil];
            tex = [[CCTexture alloc] initWithImage:image options:nil];

            if(tex){
                dispatch_sync(_dictQueue, ^{
                    [_textures setObject: tex forKey:path];
                    CCLOGINFO(@"Texture %@ cached: %p", path, tex);
                });
            } else {
                CCLOG(@"cocos2d: Couldn't create texture for file:%@ in CCTextureCache", path);
            }
        }
	}

	return((id)tex.proxy);
}


-(CCTexture*) addCGImage: (CGImageRef) imageref forKey: (NSString *)key
{
	NSAssert(imageref != nil, @"TextureCache: image MUST not be nill");

	__block CCTexture * tex = nil;

	// If key is nil, then create a new texture each time
	if( key ) {
		dispatch_sync(_dictQueue, ^{
			tex = [_textures objectForKey:key];
		});
		if(tex)
			return((id)tex.proxy);
	}
    
    CCImage *image = [[CCImage alloc] initWithCGImage:imageref contentScale:1.0 options:nil];
	tex = [[CCTexture alloc] initWithImage:image options:nil];

	if(tex && key){
		dispatch_sync(_dictQueue, ^{
			[_textures setObject: tex forKey:key];
		});
	}else{
		CCLOG(@"cocos2d: Couldn't add CGImage in CCTextureCache");
	}

	return((id)tex.proxy);
}

#pragma mark TextureCache - Remove

-(void) removeAllTextures
{
	dispatch_sync(_dictQueue, ^{
		[_textures removeAllObjects];
	});
}

-(void) removeUnusedTextures
{
    dispatch_sync(_dictQueue, ^{
        NSArray *keys = [_textures allKeys];
        for(id key in keys)
        {
            CCTexture *texture = [_textures objectForKey:key];
            CCLOGINFO(@"texture: %@", texture);
            // If the weakly retained proxy object is nil, then the texture is unreferenced.
            if (!texture.hasProxy)
            {
                CCLOGINFO(@"cocos2d: CCTextureCache: removing unused texture: %@", key);
                [_textures removeObjectForKey:key];
            }
        }
        CCLOGINFO(@"Purge complete.");
    });
}

-(void) removeTexture: (CCTexture*) tex
{
	if( ! tex )
		return;

	dispatch_sync(_dictQueue, ^{
		NSArray *keys = [_textures allKeysForObject:tex];

		for( NSUInteger i = 0; i < [keys count]; i++ )
			[_textures removeObjectForKey:[keys objectAtIndex:i]];
	});
}

-(void) removeTextureForKey:(NSString*)name
{
	if( ! name )
		return;

	dispatch_sync(_dictQueue, ^{
		[_textures removeObjectForKey:name];
	});
}

#pragma mark TextureCache - Get
- (CCTexture *)textureForKey:(NSString *)key
{
	__block CCTexture *tex = nil;

	dispatch_sync(_dictQueue, ^{
		tex = [_textures objectForKey:key];
	});

	return((id)tex.proxy);
}

@end


@implementation CCTextureCache (PVRSupport)

-(CCTexture*) addPVRImage:(NSString*)path
{
	NSAssert(path != nil, @"TextureCache: fileimage MUST not be nill");

	// remove possible -HD suffix to prevent caching the same image twice (issue #1040)
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
	path = [fileUtils standarizePath:path];

	__block CCTexture * tex;
	
	dispatch_sync(_dictQueue, ^{
		tex = [_textures objectForKey:path];
	});

	if(tex) {
		return((id)tex.proxy);
	}
    
	tex = [[CCTexture alloc] initPVRWithCCFile:[CCFileUtils fileNamed:path] options:nil];
	if( tex ){
		dispatch_sync(_dictQueue, ^{
			[_textures setObject: tex forKey:path];
		});
	}else{
		CCLOG(@"cocos2d: Couldn't add PVRImage:%@ in CCTextureCache",path);
	}

	return((id)tex.proxy);
}

@end


@implementation CCTextureCache (Debug)

-(void) dumpCachedTextureInfo
{
	__block NSUInteger count = 0;

	dispatch_sync(_dictQueue, ^{
		for (NSString* texKey in _textures) {
			CCTexture* tex = [_textures objectForKey:texKey];
			count++;
			NSLog( @"cocos2d: \"%@\"\t%lu x %lu",
				  texKey,
				  (long)tex.sizeInPixels.width,
				  (long)tex.sizeInPixels.height);
		}
	});
	NSLog( @"cocos2d: CCTextureCache dumpDebugInfo:\t%ld textures", (long)count);
}

@end
