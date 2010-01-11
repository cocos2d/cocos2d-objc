/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCTextureCache.h"
#import "CCSpriteFrame.h"
#import "ccMacros.h"

#pragma mark -
#pragma mark CCAnimation

@implementation CCAnimation
@synthesize name=name_, delay=delay_, frames=frames_;

+(id) animationWithName:(NSString*)aname delay:(float)d frames:(NSArray*)array
{
	return [[[self alloc] initWithName:aname delay:d frames:array] autorelease];
}

+(id) animationWithName:(NSString*)aname delay:(float)d
{
	return [[[self alloc] initWithName:aname delay:d] autorelease];
}

-(id) initWithName:(NSString*)t delay:(float)d
{
	return [self initWithName:t delay:d frames:nil];
}

-(id) initWithName:(NSString*)name delay:(float)delay frames:(NSArray*)array
{
	if( (self=[super init]) ) {

		delay_ = delay;
		self.name = name;
		self.frames = [NSMutableArray arrayWithArray:array];
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | name=%@, frames=%d>", [self class], self,
			name_,
			[frames_ count] ];
}

-(void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@",self);
	[name_ release];
	[frames_ release];
	[super dealloc];
}

-(void) addFrame:(CCSpriteFrame*)frame
{
	[frames_ addObject:frame];
}

-(void) addFrameWithFilename:(NSString*)filename
{
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:filename];
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect offset:CGPointZero];
	[frames_ addObject:frame];
}

-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect offset:CGPointZero];
	[frames_ addObject:frame];
}

@end

#pragma mark -
#pragma mark CCSpriteFrame
@implementation CCSpriteFrame
@synthesize rect = rect_, offset = offset_, texture = texture_;
@synthesize originalSize=originalSize_;

+(id) frameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset
{
	return [[[self alloc] initWithTexture:texture rect:rect offset:offset originalSize:rect.size] autorelease];
}

+(id) frameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	return [[[self alloc] initWithTexture:texture rect:rect offset:offset originalSize:originalSize] autorelease];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset
{
	return [self initWithTexture:texture rect:rect offset:offset originalSize:rect.size];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset originalSize:(CGSize)originalSize
{
	if( (self=[super init]) ) {
		self.texture = texture;
		offset_ = offset;
		rect_ = rect;
		originalSize_ = originalSize;
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | TextureName=%d, Rect = (%.2f,%.2f,%.2f,%.2f)>", [self class], self,
			texture_.name,
			rect_.origin.x,
			rect_.origin.y,
			rect_.size.width,
			rect_.size.height];
}

- (void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@",self);
	[texture_ release];
	[super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithTexture:texture_ rect:rect_ offset:offset_ originalSize:originalSize_];
	return copy;
}
@end
