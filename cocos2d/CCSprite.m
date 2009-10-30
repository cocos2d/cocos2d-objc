/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
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

#import "CCTextureMgr.h"
#import "CCSprite.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

#pragma mark Sprite

@interface CCSprite (Private)
// lazy allocation
-(void) initAnimationDictionary;
@end

@implementation CCSprite

#pragma mark Sprite - image file
+ (id) spriteWithFile:(NSString*) filename
{
	return [[[self alloc] initWithFile:filename] autorelease];
}

- (id) initWithFile:(NSString*) filename
{
	self = [super init];
	if( self ) {
		// texture is retained
		self.texture = [[CCTextureMgr sharedTextureMgr] addImage: filename];
		
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
		// XXX: possible bug. See issue #349. New API should be added
		NSString *key = [NSString stringWithFormat:@"%08X",(unsigned long)image];
		self.texture = [[CCTextureMgr sharedTextureMgr] addCGImage:image forKey:key];


		// lazy alloc
		animations = nil;
	}
	
	return self;
}

#pragma mark Sprite - Texture2D

+ (id)  spriteWithTexture:(CCTexture2D*) tex
{
	return [[[self alloc] initWithTexture:tex] autorelease];
}

- (id) initWithTexture:(CCTexture2D*) tex
{
	if( (self = [super init]) ) {
		// texture is retained
		self.texture = tex;

		// lazy alloc
		animations = nil;
	}
	return self;
}	

#pragma mark Sprite

-(void) dealloc
{
	[animations release];
	[super dealloc];
}

-(void) initAnimationDictionary
{
	animations = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
}

//
// CCNodeFrames protocol
//
-(void) setDisplayFrame:(id)frame
{
	self.texture = frame;
}

-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex
{
	if( ! animations )
		[self initAnimationDictionary];
	
	CCAnimation *a = [animations objectForKey: animationName];
	CCTexture2D *frame = [[a frames] objectAtIndex:frameIndex];
	self.texture = frame;	
}

-(BOOL) isFrameDisplayed:(id)frame
{
	return texture_ == frame;
}
-(id) displayFrame
{
	return texture_;
}
-(void) addAnimation: (id<CCAnimation>) anim
{
	// lazy alloc
	if( ! animations )
		[self initAnimationDictionary];
	
	[animations setObject:anim forKey:[anim name]];
}
-(id<CCAnimation>)animationByName: (NSString*) animationName
{
	NSAssert( animationName != nil, @"animationName parameter must be non nil");
    return [animations objectForKey:animationName];
}
@end

#pragma mark -
#pragma mark Animation

@implementation CCAnimation
@synthesize name, delay, frames;

+(id) animationWithName:(NSString*)n delay:(float)d
{
	return [[[self alloc] initWithName:n delay:d] autorelease];
}

-(id) initWithName: (NSString*) n delay:(float)d
{
	return [self initWithName:n delay:d firstImage:nil vaList:nil];
}

-(void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@",self);
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
		CCTexture2D *tex = [[CCTextureMgr sharedTextureMgr] addImage: image];
		[frames addObject:tex];

		NSString *filename = va_arg(args, NSString*);
		while(filename) {
			tex = [[CCTextureMgr sharedTextureMgr] addImage: filename];
			[frames addObject:tex];
		
			filename = va_arg(args, NSString*);
		}	
	}
	return self;
}

-(void) addFrameWithFilename: (NSString*) filename
{
	CCTexture2D *tex = [[CCTextureMgr sharedTextureMgr] addImage: filename];
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

-(id) initWithName:(NSString*)n delay:(float)d firstTexture:(CCTexture2D*)tex vaList:(va_list)args
{
	self = [super init];
	if( self ) {
		name = [n retain];
		frames = [[NSMutableArray array] retain];
		delay = d;
		
		if( tex ) {
			[frames addObject:tex];
			
			CCTexture2D *newTex = va_arg(args, CCTexture2D*);
			while(newTex) {
				[frames addObject:newTex];
				
				newTex = va_arg(args, CCTexture2D*);
			}	
		}
	}
	return self;
}

-(void) addFrameWithTexture: (CCTexture2D*) tex
{
	[frames addObject:tex];
}

@end

