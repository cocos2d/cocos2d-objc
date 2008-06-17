//
//  CameraAction.h
//  cocos2d
//

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