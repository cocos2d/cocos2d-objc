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
	CCCamera *camera = [target_ camera];
	[camera centerX:&centerXOrig_ centerY:&centerYOrig_ centerZ:&centerZOrig_];
	[camera eyeX:&eyeXOrig_ eyeY:&eyeYOrig_ eyeZ:&eyeZOrig_];
	[camera upX:&upXOrig_ upY:&upYOrig_ upZ: &upZOrig_];
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
	return [[[self class] allocWithZone: zone] initWithDuration:duration_ radius:radius_ deltaRadius:deltaRadius_ angleZ:angleZ_ deltaAngleZ:deltaAngleZ_ angleX:angleX_ deltaAngleX:deltaAngleX_];
}


-(id) initWithDuration:(float)t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx
{
	if((self=[super initWithDuration:t]) ) {
	
		radius_ = r;
		deltaRadius_ = dr;
		angleZ_ = z;
		deltaAngleZ_ = dz;
		angleX_ = x;
		deltaAngleX_ = dx;

		radDeltaZ_ = (CGFloat)CC_DEGREES_TO_RADIANS(dz);
		radDeltaX_ = (CGFloat)CC_DEGREES_TO_RADIANS(dx);
	}
	
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	float r, zenith, azimuth;
	
	[self sphericalRadius: &r zenith:&zenith azimuth:&azimuth];
	
#if 0 // isnan() is not supported on the simulator, and isnan() always returns false.
	if( isnan(radius_) )
		radius_ = r;
	if( isnan( angleZ_) )
		angleZ_ = (CGFloat)CC_RADIANS_TO_DEGREES(zenith);
	if( isnan( angleX_ ) )
		angleX_ = (CGFloat)CC_RADIANS_TO_DEGREES(azimuth);
#endif

	radZ_ = (CGFloat)CC_DEGREES_TO_RADIANS(angleZ_);
	radX_ = (CGFloat)CC_DEGREES_TO_RADIANS(angleX_);
}

-(void) update: (ccTime) dt
{
	float r = (radius_ + deltaRadius_ * dt) *[CCCamera getZEye];
	float za = radZ_ + radDeltaZ_ * dt;
	float xa = radX_ + radDeltaX_ * dt;

	float i = sinf(za) * cosf(xa) * r + centerXOrig_;
	float j = sinf(za) * sinf(xa) * r + centerYOrig_;
	float k = cosf(za) * r + centerZOrig_;

	[[target_ camera] setEyeX:i eyeY:j eyeZ:k];
	
}

-(void) sphericalRadius:(float*) newRadius zenith:(float*) zenith azimuth:(float*) azimuth
{
	float ex, ey, ez, cx, cy, cz, x, y, z;
	float r; // radius
	float s;
	
	CCCamera *camera = [target_ camera];
	[camera eyeX:&ex eyeY:&ey eyeZ:&ez];
	[camera centerX:&cx centerY:&cy centerZ:&cz];
	
	x = ex-cx;
	y = ey-cy;
	z = ez-cz;
	
	r = sqrtf( powf(x,2) + powf(y,2) + powf(z,2));
	s = sqrtf( powf(x,2) + powf(y,2));
	if(s==0.0f)
		s=FLT_EPSILON;
	if(r==0.0f)
		r=FLT_EPSILON;

	*zenith = acosf( z/r);
	if( x < 0 )
		*azimuth= (float)M_PI - asinf(y/s);
	else
		*azimuth = asinf(y/s);
					
	*newRadius = r / [CCCamera getZEye];					
}
@end
