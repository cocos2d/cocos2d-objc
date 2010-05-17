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



#import "CCCameraAction.h"
#import "CCNode.h"
#import "CCCamera.h"
#import "ccMacros.h"

//
// CameraAction
//
@implementation CCCameraAction
-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	CCCamera *camera = [target camera];
	[camera centerX:&centerXOrig centerY:&centerYOrig centerZ: &centerZOrig];
	[camera eyeX:&eyeXOrig eyeY:&eyeYOrig eyeZ: &eyeZOrig];
	[camera upX:&upXOrig upY:&upYOrig upZ: &upZOrig];
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
	return [[[self class] allocWithZone: zone] initWithDuration:duration radius:radius deltaRadius:deltaRadius angleZ:angleZ deltaAngleZ:deltaAngleZ angleX:angleX deltaAngleX:deltaAngleX];
}


-(id) initWithDuration:(float)t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx
{
	if((self=[super initWithDuration:t]) ) {
	
		radius = r;
		deltaRadius = dr;
		angleZ = z;
		deltaAngleZ = dz;
		angleX = x;
		deltaAngleX = dx;

		radDeltaZ = (CGFloat)CC_DEGREES_TO_RADIANS(dz);
		radDeltaX = (CGFloat)CC_DEGREES_TO_RADIANS(dx);
	}
	
	return self;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	float r, zenith, azimuth;
	
	[self sphericalRadius: &r zenith:&zenith azimuth:&azimuth];
	if( isnan(radius) )
		radius = r;
	if( isnan(angleZ) )
		angleZ = (CGFloat)CC_RADIANS_TO_DEGREES(zenith);
	if( isnan(angleX) )
		angleX = (CGFloat)CC_RADIANS_TO_DEGREES(azimuth);

	radZ = (CGFloat)CC_DEGREES_TO_RADIANS(angleZ);
	radX = (CGFloat)CC_DEGREES_TO_RADIANS(angleX);
}

-(void) update: (ccTime) dt
{
	float r = (radius + deltaRadius * dt) *[CCCamera getZEye];
	float za = radZ + radDeltaZ * dt;
	float xa = radX + radDeltaX * dt;

	float i = sinf(za) * cosf(xa) * r + centerXOrig;
	float j = sinf(za) * sinf(xa) * r + centerYOrig;
	float k = cosf(za) * r + centerZOrig;

	[[target camera] setEyeX:i eyeY:j eyeZ:k];
	
}

-(void) sphericalRadius:(float*) newRadius zenith:(float*) zenith azimuth:(float*) azimuth
{
	float ex, ey, ez, cx, cy, cz, x, y, z;
	float r; // radius
	float s;
	
	CCCamera *camera = [target camera];
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
