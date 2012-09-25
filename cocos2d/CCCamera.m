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
 */


#import "Platforms/CCGL.h"
#import "CCCamera.h"
#import "ccMacros.h"
#import "CCDrawingPrimitives.h"

@implementation CCCamera

@synthesize dirty = dirty_;

-(id) init
{
	if( (self=[super init]) )
		[self restore];

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | center = (%.2f,%.2f,%.2f)>", [self class], self, centerX_, centerY_, centerZ_];
}


- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(void) restore
{
	eyeX_ = eyeY_ = 0;
	eyeZ_ = [CCCamera getZEye];

	centerX_ = centerY_ = centerZ_ = 0;

	upX_ = 0.0f;
	upY_ = 1.0f;
	upZ_ = 0.0f;

	dirty_ = NO;
}

-(void) locate
{
	if( dirty_ )
		gluLookAt( eyeX_, eyeY_, eyeZ_,
				centerX_, centerY_, centerZ_,
				upX_, upY_, upZ_
				);
}

+(float) getZEye
{
	return FLT_EPSILON;
//	CGSize s = [[CCDirector sharedDirector] displaySize];
//	return ( s.height / 1.1566f );
}

-(void) setEyeX: (float)x eyeY:(float)y eyeZ:(float)z
{
	eyeX_ = x * CC_CONTENT_SCALE_FACTOR();
	eyeY_ = y * CC_CONTENT_SCALE_FACTOR();
	eyeZ_ = z * CC_CONTENT_SCALE_FACTOR();
	dirty_ = YES;
}

-(void) setCenterX: (float)x centerY:(float)y centerZ:(float)z
{
	centerX_ = x * CC_CONTENT_SCALE_FACTOR();
	centerY_ = y * CC_CONTENT_SCALE_FACTOR();
	centerZ_ = z * CC_CONTENT_SCALE_FACTOR();
	dirty_ = YES;
}

-(void) setUpX: (float)x upY:(float)y upZ:(float)z
{
	upX_ = x;
	upY_ = y;
	upZ_ = z;
	dirty_ = YES;
}

-(void) eyeX: (float*)x eyeY:(float*)y eyeZ:(float*)z
{
	*x = eyeX_ / CC_CONTENT_SCALE_FACTOR();
	*y = eyeY_ / CC_CONTENT_SCALE_FACTOR();
	*z = eyeZ_ / CC_CONTENT_SCALE_FACTOR();
}

-(void) centerX: (float*)x centerY:(float*)y centerZ:(float*)z
{
	*x = centerX_ / CC_CONTENT_SCALE_FACTOR();
	*y = centerY_ / CC_CONTENT_SCALE_FACTOR();
	*z = centerZ_ / CC_CONTENT_SCALE_FACTOR();
}

-(void) upX: (float*)x upY:(float*)y upZ:(float*)z
{
	*x = upX_;
	*y = upY_;
	*z = upZ_;
}

@end
