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

#import "ccMacros.h"
#import "CCAnimation.h"
#import "CCSpriteFrame.h"
#import "CCTexture2D.h"
#import "CCTextureCache.h"

@implementation CCAnimation
@synthesize name = name_, delay = delay_, frames = frames_;

+(id) animation
{
	return [[[self alloc] init] autorelease];
}

+(id) animationWithFrames:(NSArray*)frames
{
	return [[[self alloc] initWithFrames:frames] autorelease];
}

+(id) animationWithFrames:(NSArray*)frames delay:(float)delay
{
	return [[[self alloc] initWithFrames:frames delay:delay] autorelease];
}

-(id) init
{
	return [self initWithFrames:nil delay:0];
}

-(id) initWithFrames:(NSArray*)frames
{
	return [self initWithFrames:frames delay:0];
}

-(id) initWithFrames:(NSArray*)array delay:(float)delay
{
	if( (self=[super init]) ) {
		
		delay_ = delay;
		self.frames = [NSMutableArray arrayWithArray:array];
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | frames=%d, delay:%f>", [self class], self,
			[frames_ count],
			delay_
			];
}

-(void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);
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
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect];
	[frames_ addObject:frame];
}

-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect];
	[frames_ addObject:frame];
}

@end
