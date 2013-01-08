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
#import "kazmath/GL/matrix.h"

@implementation CCCamera

@synthesize dirty = _dirty;

-(id) init
{
	if( (self=[super init]) )
		[self restore];

	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | center = (%.2f,%.2f,%.2f)>", [self class], self, _centerX, _centerY, _centerZ];
}


- (void) dealloc
{
	CCLOGINFO(@"cocos2d: deallocing %@", self);
	[super dealloc];
}

-(void) restore
{
	_eyeX = _eyeY = 0;
	_eyeZ = [CCCamera getZEye];

	_centerX = _centerY = _centerZ = 0;

	_upX = 0.0f;
	_upY = 1.0f;
	_upZ = 0.0f;

	kmMat4Identity( &_lookupMatrix );

	_dirty = NO;
}

-(void) locate
{
	if( _dirty ) {

		kmVec3 eye, center, up;

		kmVec3Fill( &eye, _eyeX, _eyeY , _eyeZ );
		kmVec3Fill( &center, _centerX, _centerY, _centerZ );

		kmVec3Fill( &up, _upX, _upY, _upZ);
		kmMat4LookAt( &_lookupMatrix, &eye, &center, &up);

		_dirty = NO;

	}

	kmGLMultMatrix( &_lookupMatrix );

}

+(float) getZEye
{
	return FLT_EPSILON;
	//	CGSize s = [[CCDirector sharedDirector] displaySize];
	//	return ( s.height / 1.1566f );
}

-(void) setEyeX: (float)x eyeY:(float)y eyeZ:(float)z
{
	_eyeX = x;
	_eyeY = y;
	_eyeZ = z;

	_dirty = YES;
}

-(void) setCenterX: (float)x centerY:(float)y centerZ:(float)z
{
	_centerX = x;
	_centerY = y;
	_centerZ = z;

	_dirty = YES;
}

-(void) setUpX: (float)x upY:(float)y upZ:(float)z
{
	_upX = x;
	_upY = y;
	_upZ = z;

	_dirty = YES;
}

-(void) eyeX: (float*)x eyeY:(float*)y eyeZ:(float*)z
{
	*x = _eyeX;
	*y = _eyeY;
	*z = _eyeZ;
}

-(void) centerX: (float*)x centerY:(float*)y centerZ:(float*)z
{
	*x = _centerX;
	*y = _centerY;
	*z = _centerZ;
}

-(void) upX: (float*)x upY:(float*)y upZ:(float*)z
{
	*x = _upX;
	*y = _upY;
	*z = _upZ;
}

@end
