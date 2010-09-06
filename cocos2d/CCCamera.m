/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
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

@synthesize dirty;

-(id) init
{
	if( (self=[super init]) )
		[self restore];
	
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | center = (%.2f,%.2f,%.2f)>", [self class], self, centerX, centerY, centerZ];
}


- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(void) restore
{
	eyeX = eyeY = 0;
	eyeZ = [CCCamera getZEye];
	
	centerX = centerY = centerZ = 0;
	
	upX = 0.0f;
	upY = 1.0f;
	upZ = 0.0f;
	
	dirty = NO;
}

-(void) locate
{
	if( dirty )
		gluLookAt( eyeX, eyeY, eyeZ,
				centerX, centerY, centerZ,
				upX, upY, upZ
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
	eyeX = x;
	eyeY = y;
	eyeZ = z;
	dirty = YES;	
}

-(void) setCenterX: (float)x centerY:(float)y centerZ:(float)z
{
	centerX = x;
	centerY = y;
	centerZ = z;
	dirty = YES;
}

-(void) setUpX: (float)x upY:(float)y upZ:(float)z
{
	upX = x;
	upY = y;
	upZ = z;
	dirty = YES;
}

-(void) eyeX: (float*)x eyeY:(float*)y eyeZ:(float*)z
{
	*x = eyeX;
	*y = eyeY;
	*z = eyeZ;
}

-(void) centerX: (float*)x centerY:(float*)y centerZ:(float*)z
{
	*x = centerX;
	*y = centerY;
	*z = centerZ;
}

-(void) upX: (float*)x upY:(float*)y upZ:(float*)z
{
	*x = upX;
	*y = upY;
	*z = upZ;
}

@end
