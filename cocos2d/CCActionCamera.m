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



#import "CCActionCamera.h"
#import "CCNode.h"
#import "CCCamera.h"
#import "ccMacros.h"

//
// CameraAction
//
@implementation CCActionCamera
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CCCamera *camera = [_target camera];
	[camera centerX:&_centerXOrig centerY:&_centerYOrig centerZ:&_centerZOrig];
	[camera eyeX:&_eyeXOrig eyeY:&_eyeYOrig eyeZ:&_eyeZOrig];
	[camera upX:&_upXOrig upY:&_upYOrig upZ: &_upZOrig];
}

-(id) reverse
{
	return [CCReverseTime actionWithAction:self];
}
@end

@implementation CCOrbitCamera
+(id) actionWithDuration:(float)t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx
{
	return [[[self alloc] initWithDuration:t radius:r deltaRadius:dr angleZ:z deltaAngleZ:dz angleX:x deltaAngleX:dx] autorelease];
}

-(id) copyWithZone: (NSZone*) zone
{
	return [[[self class] allocWithZone: zone] initWithDuration:_duration radius:_radius deltaRadius:_deltaRadius angleZ:_angleZ deltaAngleZ:_deltaAngleZ angleX:_angleX deltaAngleX:_deltaAngleX];
}


-(id) initWithDuration:(float)t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx
{
	if((self=[super initWithDuration:t]) ) {

		_radius = r;
		_deltaRadius = dr;
		_angleZ = z;
		_deltaAngleZ = dz;
		_angleX = x;
		_deltaAngleX = dx;

		_radDeltaZ = (CGFloat)CC_DEGREES_TO_RADIANS(dz);
		_radDeltaX = (CGFloat)CC_DEGREES_TO_RADIANS(dx);
	}

	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	float r, zenith, azimuth;

	[self sphericalRadius: &r zenith:&zenith azimuth:&azimuth];

#if 0 // isnan() is not supported on the simulator, and isnan() always returns false.
	if( isnan(_radius) )
		_radius = r;

	if( isnan( _angleZ) )
		_angleZ = (CGFloat)CC_RADIANS_TO_DEGREES(zenith);

	if( isnan( _angleX ) )
		_angleX = (CGFloat)CC_RADIANS_TO_DEGREES(azimuth);
#endif

	_radZ = (CGFloat)CC_DEGREES_TO_RADIANS(_angleZ);
	_radX = (CGFloat)CC_DEGREES_TO_RADIANS(_angleX);
}

-(void) update: (ccTime) dt
{
	float r = (_radius + _deltaRadius * dt) *[CCCamera getZEye];
	float za = _radZ + _radDeltaZ * dt;
	float xa = _radX + _radDeltaX * dt;

	float i = sinf(za) * cosf(xa) * r + _centerXOrig;
	float j = sinf(za) * sinf(xa) * r + _centerYOrig;
	float k = cosf(za) * r + _centerZOrig;

	[[_target camera] setEyeX:i eyeY:j eyeZ:k];
}

-(void) sphericalRadius:(float*) newRadius zenith:(float*) zenith azimuth:(float*) azimuth
{
	float ex, ey, ez, cx, cy, cz, x, y, z;
	float r; // radius
	float s;

	CCCamera *camera = [_target camera];
	[camera eyeX:&ex eyeY:&ey eyeZ:&ez];
	[camera centerX:&cx centerY:&cy centerZ:&cz];

	x = ex-cx;
	y = ey-cy;
	z = ez-cz;

	r = sqrtf( x*x + y*y + z*z);
	s = sqrtf( x*x + y*y);
	if(s==0.0f)
		s = FLT_EPSILON;
	if(r==0.0f)
		r = FLT_EPSILON;

	*zenith = acosf( z/r);
	if( x < 0 )
		*azimuth = (float)M_PI - asinf(y/s);
	else
		*azimuth = asinf(y/s);

	*newRadius = r / [CCCamera getZEye];
}
@end
