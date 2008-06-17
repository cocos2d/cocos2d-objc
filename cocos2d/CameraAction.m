//
//  CameraAction.m
//  cocos2d
//


#import "CameraAction.h"
#import "CocosNode.h"
#import "Camera.h"
#import "OpenGL_Internal.h"

//
// CameraAction
//
@implementation CameraAction
-(void) start
{
	[super start];
	[[target camera] centerX:&centerXOrig centerY:&centerYOrig centerZ: &centerZOrig];
	[[target camera] eyeX:&eyeXOrig eyeY:&eyeYOrig eyeZ: &eyeZOrig];
	[[target camera] upX:&upXOrig upY:&upYOrig upZ: &upZOrig];
}
@end

@implementation OrbitCamera
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
	if(! [super initWithDuration:t])
		return nil;
	
	radius = r;
	deltaRadius = dr;
	angleZ = z;
	deltaAngleZ = dz;
	angleX = x;
	deltaAngleX = dx;

	radDeltaZ = DEGREES_TO_RADIANS(dz);
	radDeltaX = DEGREES_TO_RADIANS(dx);
	
	return self;
}

-(void) start
{
	[super start];
	float r, zenith, azimuth;
	
	[self sphericalRadius: &r zenith:&zenith azimuth:&azimuth];
	if( isnan(radius) )
		radius = r;
	if( isnan(angleZ) )
		angleZ = RADIANS_TO_DEGREES(zenith);
	if( isnan(angleX) )
		angleX = RADIANS_TO_DEGREES(azimuth);

	radZ = DEGREES_TO_RADIANS(angleZ);
	radX = DEGREES_TO_RADIANS(angleX);
}

-(void) update: (double) t
{
	float r = (radius + deltaRadius * t) *[Camera getZEye];
	float za = radZ + radDeltaZ * t;
	float xa = radX + radDeltaX * t;

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
	
	[[target camera] eyeX:&ex eyeY:&ey eyeZ:&ez];
	[[target camera] centerX:&cx centerY:&cy centerZ:&cz];
	
	x = ex-cx;
	y = ey-cy;
	z = ez-cz;
	
	r = sqrtf( powf(x,2) + powf(y,2) + powf(z,2));
	s = sqrtf( powf(x,2) + powf(y,2));
	if(s==0.0f)
		s=0.00000001f;
	if(r==0.0f)
		r=0.00000001f;

	*zenith = acosf( z/r);
	if( x < 0 )
		*azimuth= M_PI - asinf(y/s);
	else
		*azimuth = asinf(y/s);
					
	*newRadius = r / [Camera getZEye];					
}
@end
