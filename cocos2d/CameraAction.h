/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#import "IntervalAction.h"

/** Base class for Camera actions
 */
@interface CameraAction : IntervalAction <NSCopying> {
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

/** Orbit Camera action
 Orbits the camera around the center of the screen using spherical coordinates
 */
@interface OrbitCamera : CameraAction <NSCopying> {
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
+(id) actionWithDuration:(float) t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx;
-(id) initWithDuration:(float) t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx;
-(void) sphericalRadius:(float*) r zenith:(float*) zenith azimuth:(float*) azimuth;
@end
