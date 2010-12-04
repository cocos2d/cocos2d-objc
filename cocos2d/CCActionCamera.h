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

#import "CCActionInterval.h"

@class CCCamera;

/** Base class for CCCamera actions
 */
@interface CCActionCamera : CCActionInterval <NSCopying>
{	
	float centerXOrig_;
	float centerYOrig_;
	float centerZOrig_;
	
	float eyeXOrig_;
	float eyeYOrig_;
	float eyeZOrig_;
	
	float upXOrig_;
	float upYOrig_;
	float upZOrig_;
}
@end

/** CCOrbitCamera action
 Orbits the camera around the center of the screen using spherical coordinates
 */
@interface CCOrbitCamera : CCActionCamera <NSCopying>
{
	float radius_;
	float deltaRadius_;
	float angleZ_;
	float deltaAngleZ_;
	float angleX_;
	float deltaAngleX_;
	
	float radZ_;
	float radDeltaZ_;
	float radX_;
	float radDeltaX_;
	
}
/** creates a CCOrbitCamera action with radius, delta-radius,  z, deltaZ, x, deltaX */
+(id) actionWithDuration:(float) t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx;
/** initializes a CCOrbitCamera action with radius, delta-radius,  z, deltaZ, x, deltaX */
-(id) initWithDuration:(float) t radius:(float)r deltaRadius:(float) dr angleZ:(float)z deltaAngleZ:(float)dz angleX:(float)x deltaAngleX:(float)dx;
/** positions the camera according to spherical coordinates */
-(void) sphericalRadius:(float*) r zenith:(float*) zenith azimuth:(float*) azimuth;
@end
