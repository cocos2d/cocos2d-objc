/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCTextureMgr.h"
#import "CCSpriteFrame.h"
#import "ccMacros.h"

#pragma mark -
#pragma mark CCAnimation

@implementation CCAnimation
@synthesize name, delay, frames;

+(id) animationWithName:(NSString*)aname delay:(float)d array:(NSArray*)array
{
	return [[[self alloc] initWithName:aname delay:d array:array] autorelease];
}

+(id) animationWithName:(NSString*)aname delay:(float)d
{
	return [[[self alloc] initWithName:aname delay:d] autorelease];
}

-(id) initWithName:(NSString*)t delay:(float)d
{
	return [self initWithName:t delay:d array:nil];
}

-(id) initWithName:(NSString*)n delay:(float)d array:(NSArray*)array
{
	if( (self=[super init]) ) {
		
		name = n;
		delay = d;
		self.frames = [NSMutableArray arrayWithArray:array];
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | frames=%d>", [self class], self,
			[frames count] ];
}

-(void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@",self);
	[frames release];
	[super dealloc];
}

-(void) addFrame:(CCSpriteFrame*)frame;
{
	[frames addObject:frame];
}

-(void) addFrameWithFilename:(NSString*)filename
{
	CCTexture2D *texture = [[CCTextureMgr sharedTextureMgr] addImage:filename];
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect offset:CGPointZero];
	[frames addObject:frame];
}
@end

#pragma mark -
#pragma mark CCSpriteFrame
@implementation CCSpriteFrame
@synthesize rect = rect_, offset = offset_, texture = texture_;

+(id) frameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset
{
	return [[[self alloc] initWithTexture:texture rect:rect offset:offset] autorelease];
}

+(id) frameWithRect:(CGRect)rect
{
	return [[[self alloc] initWithTexture:nil rect:rect offset:CGPointZero] autorelease];
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect offset:(CGPoint)offset
{
	if( (self=[super init]) ) {
		self.texture = texture;
		offset_ = offset;
		rect_ = rect;
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
@end
