/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "TextureMgr.h"
#import "Sprite.h"

#pragma mark Sprite

@interface Sprite (Private)
// lazy allocation
-(void) initAnimationDictionary;
@end

@implementation Sprite

#pragma mark Sprite - image file
+ (id) spriteWithFile: (NSString*) filename
{
	return [[[self alloc] initWithFile:filename] autorelease];
}

- (id) initWithFile: (NSString*) filename
{
	self = [super init];
	if( self ) {
		self.texture = [[[TextureMgr sharedTextureMgr] addImage: filename] retain];
	}
	
	return self;
}

#pragma mark Sprite - PVRTC RAW

+ (id) spriteWithPVRTCFile: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	return [[[self alloc] initWithPVRTCFile:fileimage bpp:bpp hasAlpha:alpha width:w] autorelease];
}

- (id) initWithPVRTCFile: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	self=[super init];
	if( self ) {
		self.texture = [[[TextureMgr sharedTextureMgr] addPVRTCImage:fileimage bpp:bpp hasAlpha:alpha width:w] retain];
		
		// lazy alloc
		animations = nil;
	}
	
	return self;
}

#pragma mark Sprite - CGImageRef

+ (id) spriteWithCGImage: (CGImageRef) image
{
	return [[[self alloc] initWithCGImage:image] autorelease];
}

- (id) initWithCGImage: (CGImageRef) image
{
	self = [super init];
	if( self ) {
		self.texture = [[[TextureMgr sharedTextureMgr] addCGImage: image] retain];
		
		// lazy alloc
		animations = nil;
	}
	
	return self;
}

#pragma mark Sprite - Texture2D

+ (id)  spriteWithTexture:(Texture2D*) tex
{
	return [[[self alloc] initWithTexture:tex] autorelease];
}

- (id) initWithTexture:(Texture2D*) tex
{
	self = [super init];
	if( self ) {
		self.texture = [tex retain];
		
		// lazy alloc
		animations = nil;
	}
	return self;
}	

#pragma mark Sprite - TextureNode override

-(void) setTexture: (Texture2D *) aTexture
{
	super.texture = aTexture;
	CGSize s = aTexture.contentSize;
	self.transformAnchor = cpv(s.width/2, s.height/2);
}

#pragma mark Sprite

-(void) dealloc
{
	[texture release];
	[animations release];
	[super dealloc];
}

-(void) initAnimationDictionary
{
	animations = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
}

-(void) addAnimation: (Animation*) anim
{
	// lazy alloc
	if( ! animations )
		[self initAnimationDictionary];
	
	[animations setObject:anim forKey:[anim name]];
}

-(Animation *)animationByName: (NSString*) animationName
{
	NSAssert( animationName != nil, @"animationName parameter must be non nil");
    return [animations objectForKey:animationName];
}

-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex
{
	if( ! animations )
		[self initAnimationDictionary];

	Animation *a = [animations objectForKey: animationName];
	Texture2D *tex = [[a frames] objectAtIndex:frameIndex];
	if( tex == texture )
		return;
	[texture release];
	texture = [tex retain];
}
@end

#pragma mark Animation

@implementation Animation
@synthesize name, delay, frames;

-(id) initWithName: (NSString*) n delay:(float)d
{
	return [self initWithName:n delay:d firstImage:nil vaList:nil];
}

-(void) dealloc
{
	[name release];
	[frames release];
	[super dealloc];
}

#pragma mark Animation - image files

+(id) animationWithName: (NSString*) name delay:(float)delay images:image1,...
{
	va_list args;
	va_start(args,image1);
	
	id s = [[[self alloc] initWithName:name delay:delay firstImage:image1 vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithName: (NSString*) n delay:(float)d firstImage:(NSString*)image vaList: (va_list) args
{
	if( ! (self=[super init]) )
		return nil;
	
	name = [n retain];
	frames = [[NSMutableArray array] retain];
	delay = d;

	if( image ) {
		Texture2D *tex = [[TextureMgr sharedTextureMgr] addImage: image];
		[frames addObject:tex];

		NSString *filename = va_arg(args, NSString*);
		while(filename) {
			tex = [[TextureMgr sharedTextureMgr] addImage: filename];
			[frames addObject:tex];
		
			filename = va_arg(args, NSString*);
		}	
	}
	return self;
}

-(void) addFrame: (NSString*) filename
{
	Texture2D *tex = [[TextureMgr sharedTextureMgr] addImage: filename];
	[frames addObject:tex];
}

#pragma mark Animation - Texture2D

+(id) animationWithName: (NSString*) name delay:(float)delay textures:tex1,...
{
	va_list args;
	va_start(args,tex1);
	
	id s = [[[self alloc] initWithName:name delay:delay firstTexture:tex1 vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithName: (NSString*) n delay:(float)d firstTexture:(Texture2D*)tex vaList:(va_list)args
{
	self = [super init];
	if( self ) {
		name = [n retain];
		frames = [[NSMutableArray array] retain];
		delay = d;
		
		if( tex ) {
			[frames addObject:tex];
			
			Texture2D *newTex = va_arg(args, Texture2D*);
			while(newTex) {
				[frames addObject:newTex];
				
				newTex = va_arg(args, Texture2D*);
			}	
		}
	}
	return self;
}

-(void) addFrameWithTexture: (Texture2D*) tex
{
	[frames addObject:tex];
}

@end

