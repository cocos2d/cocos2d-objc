/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCIntervalAction.h"

/** Base class for CCCamera actions
 */
@interface CCCameraAction : CCIntervalAction <NSCopying> {
	float centerXOrig;
	float centerYOrig;
	float centerZOrig;
	
	float eyeXOrig;
	float eyeYOrig;
	float eyeZOrig;
	
	float upXOrig;
	float upYOrig;
	float upZOrig;
}
@end

/** CCOrbitCamera action
 Orbits the camera around the center of the screen using spherical coordinates
 */
@interface CCOrbitCamera : CCCameraAction <NSCopying> {
	float radius;
	float deltaRadius;
	float angleZ;
	float deltaAngleZ;
	float angleX;
	float deltaAngleX;
	
	float radZ;
	float radDeltaZ;
	float radX;
	float radDeltaX;
	
}
/** creates a CCOrbitCamera action with radius, delta-radius,  z, deltaZ, x, deltaX */
+(id) actionWithDuration:(float) t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx;
/** initializes a CCOrbitCamera action with radius, delta-radius,  z, deltaZ, x, deltaX */
-(id) initWithDuration:(float) t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx;
/** positions the camera according to spherical coordinates */
-(void) sphericalRadius:(float*) r zenith:(float*) zenith azimuth:(float*) azimuth;
@end
