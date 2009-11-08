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

#import "CCSpriteFrame.h"
#import "ccMacros.h"

#pragma mark -
#pragma mark CCAnimation

@implementation CCAnimation
@synthesize name, delay, frames;

+(id) animationWithName:(NSString*)aname delay:(float)d frames:rect1,...
{
	va_list args;
	va_start(args,rect1);
	
	id s = [[[self alloc] initWithName:aname delay:d firstFrame:rect1 vaList:args] autorelease];
	
	va_end(args);
	return s;
}

+(id) animationWithName:(NSString*)aname delay:(float)d
{
	return [[[self alloc] initWithName:aname delay:d] autorelease];
}

-(id) initWithName:(NSString*)t delay:(float)d
{
	return [self initWithName:t delay:d firstFrame:nil vaList:nil];
}

/* initializes a CCAnimation with a name, and the frames from CCSpriteFrames */
-(id) initWithName:(NSString*)t delay:(float)d firstFrame:(CCSpriteFrame*)frame vaList:(va_list)args
{
	if( (self=[super init]) ) {
		
		name = t;
		frames = [[NSMutableArray array] retain];
		delay = d;
		
		if( frame ) {
			[frames addObject:frame];
			
			CCSpriteFrame *frame2 = va_arg(args, CCSpriteFrame*);
			while(frame2) {
				[frames addObject:frame2];
				frame2 = va_arg(args, CCSpriteFrame*);
			}	
		}
	}
	return self;
}

-(void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@",self);
	[frames release];
	[super dealloc];
}

-(void) addFrameWithRect:(CGRect)rect
{
	CCSpriteFrame *frame = [CCSpriteFrame frameWithRect:rect];
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
	return [NSString stringWithFormat:@"<%@ = %08X | Rect = (%.2f,%.2f,%.2f,%.2f)>", [self class], self,
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
