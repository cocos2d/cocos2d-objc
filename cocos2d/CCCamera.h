/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009,2010 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import "CCNode.h"

/** 
    A Camera is used in every CocosNode.
    Useful to look at the object from different views.
    The OpenGL gluLookAt() function is used to locate the
    camera.

    If the object is transformed by any of the scale, rotation or
    position attributes, then they will override the camera.
 
	IMPORTANT: Either your use the camera or the rotation/scale/position properties. You can't use both.
    World coordinates won't work if you use the camera.

    Limitations:
 
     - Some nodes, like CCParallaxNode, CCParticle uses world node coordinates, and they won't work properly if you move them (or any of their ancestors)
       using the camera.
*/

@interface CCCamera : NSObject {
    float eyeX;
    float eyeY;
    float eyeZ;

    float centerX;
    float centerY;
    float centerZ;

    float upX;
    float upY;
    float upZ;
	
	BOOL dirty;
}

/** whether of not the camera is dirty */
@property (nonatomic,readwrite) BOOL dirty;

/** returns the Z eye */
+(float) getZEye;

/** sets the camera in the defaul position */
-(void) restore;
/** Sets the camera using gluLookAt using its eye, center and up_vector */
-(void) locate;
/** sets the eye values */
-(void) setEyeX: (float)x eyeY:(float)y eyeZ:(float)z;
/** sets the center values */
-(void) setCenterX: (float)x centerY:(float)y centerZ:(float)z;
/** sets the up values */
-(void) setUpX: (float)x upY:(float)y upZ:(float)z;

/** get the eye vector values */
-(void) eyeX:(float*)x eyeY:(float*)y eyeZ:(float*)z;
/** get the center vector values */
-(void) centerX:(float*)x centerY:(float*)y centerZ:(float*)z;
/** get the up vector values */
-(void) upX:(float*)x upY:(float*)y upZ:(float*)z;


@end
