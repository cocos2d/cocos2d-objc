/*
 * kazmath.h
 *
 * $Version: cocos3d 0.5-beta (eab7e651f462) on 2011-01-31 $
 *
 * Copyright (c) 2008, Luke Benstead.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * http://www.kazade.co.uk/kazmath/
 *
 * Augmented and modified for use with Objective-C in cocos3D by Bill Hollings
 * Additions and modifications copyright (c) 2010-2011 The Brenwill Workshop Ltd. All rights reserved.
 * http://www.brenwill.com
 */

/** @file */	// Doxygen marker

#define KM_FALSE 0
#define KM_TRUE 1
#define kmScalar float

/** A three-dimensional vector. */
typedef struct kmVec3 {
	kmScalar x;
	kmScalar y;
	kmScalar z;
} kmVec3;

/** A homogeneous four-dimensional vector. */
typedef struct kmVec4 {
	kmScalar x;
	kmScalar y;
	kmScalar z;
	kmScalar w;
} kmVec4;

/** A rotational quaternion */
typedef struct kmQuaternion {
	kmScalar x;
	kmScalar y;
	kmScalar z;
	kmScalar w;
} kmQuaternion;

/** A standard 4x4 matrix
		| 0   4   8  12 |
 mat =	| 1   5   9  13 |
		| 2   6  10  14 |
		| 3   7  11  15 |
 */
typedef struct {
	kmScalar mat[16];
} kmMat4;


/** Returns a kmVec3 structure constructed from the vector components. */
kmVec3 kmVec3Make(kmScalar x, kmScalar y, kmScalar z);

/** Returns the length of the vector. */
kmScalar kmVec3Length(const kmVec3* pIn);

/** Normalizes the vector to unit length, stores the result in pOut and returns the result. */
kmVec3* kmVec3Normalize(kmVec3* pOut, const kmVec3* pIn);

/** Assigns pIn to pOut. Returns pOut. If pIn and pOut are the same then nothing happens but pOut is still returned */
kmVec3* kmVec3Assign(kmVec3* pOut, const kmVec3* pIn);

/** Subtracts 2 vectors and returns the result. The result is stored in pOut. */
kmVec3* kmVec3Subtract(kmVec3* pOut, const kmVec3* pV1, const kmVec3* pV2);

/** Returns a vector perpendicular to 2 other vectors. The result is stored in pOut. */
kmVec3* kmVec3Cross(kmVec3* pOut, const kmVec3* pV1, const kmVec3* pV2);

/** Returns a kmVec4 structure constructed from the vector components. */
kmVec4 kmVec4Make(kmScalar x, kmScalar y, kmScalar z, kmScalar w);

/** Transforms a 4D vector by a matrix, the result is stored in pOut, and pOut is returned. */
kmVec4* kmVec4Transform(kmVec4* pOut, const kmVec4* pV, const kmMat4* pM);

#pragma mark -
#pragma mark Mat4

/**
 * Sets pOut to an identity matrix returns pOut
 * @Params pOut - A pointer to the matrix to set to identity
 * @Return Returns pOut so that the call can be nested
 */
const kmMat4* kmMat4Identity(kmMat4* pOut);

/** Multiplies pM1 with pM2, stores the result in pOut, returns pOut. */
kmMat4* kmMat4Multiply(kmMat4* pOut, const kmMat4* pM1, const kmMat4* pM2);

/** Builds a translation matrix, stores the result in pOut, returns pOut. */
kmMat4* kmMat4Translation(kmMat4* pOut, const kmScalar x, const kmScalar y, const kmScalar z);

/**
 * Builds a rotation matrix that rotates around all three axes, y (yaw), x (pitch) and z (roll),
 * in that order, stores the result in pOut and returns the result.
 * This algorithm matches up along the positive Y axis, which is the OpenGL ES default.
 */
kmMat4* kmMat4RotationYXZ(kmMat4* pOut, const kmScalar xRadians, const kmScalar yRadians, const kmScalar zRadians);

/**
 * Builds a rotation matrix that rotates around all three axes z (roll), y (yaw), and x (pitch),
 * in that order, stores the result in pOut and returns the result
 * This algorithm matches up along the positive Z axis, which is used by some commercial 3D worlds.
 */
kmMat4* kmMat4RotationZYX(kmMat4* pOut, const kmScalar xRadians, const kmScalar yRadians, const kmScalar zRadians);

/** Builds a rotation matrix around the X-axis, stores the result in pOut and returns the result */
kmMat4* kmMat4RotationX(kmMat4* pOut, const float radians);

/** Builds a rotation matrix around the Y-axis, stores the result in pOut and returns the result */
kmMat4* kmMat4RotationY(kmMat4* pOut, const float radians);

/** Builds a rotation matrix around the Z-axis, stores the result in pOut and returns the result */
kmMat4* kmMat4RotationZ(kmMat4* pOut, const float radians);

/**
 * Build a rotation matrix from an axis and an angle, 
 * stores the result in pOut and returns the result.
 */
kmMat4* kmMat4RotationAxisAngle(kmMat4* pOut, const kmVec3* axis, kmScalar radians);

/** Builds a scaling matrix */
kmMat4* kmMat4Scaling(kmMat4* pOut, const kmScalar x, const kmScalar y, const kmScalar z);

/**
 * Builds a transformation matrix that translates, rotates and scales according to the specified vectors,
 * stores the result in pOut and returns the result.
 */
kmMat4* kmMat4Transformation(kmMat4* pOut, const kmVec3 translation, const kmVec3 rotation, const kmVec3 scale);

/** Get the value from the matrix at the specfied row and column. */
float kmMatGet(const kmMat4* pIn, int row, int col);

/** Set the value into the matrix at the specfied row and column. */
void kmMatSet(kmMat4 * pIn, int row, int col, float value);

/** Swap the elements in the matrix at the specfied row and column coordinates. */
void kmMatSwap(kmMat4 * pIn, int r1, int c1, int r2, int c2);

#pragma mark -
#pragma mark Projection

/** Creates a perspective projection matrix in the same way as gluPerspective. */
const kmMat4* kmMat4PerspectiveProjection(kmMat4* pOut, kmScalar fovY, kmScalar aspect, kmScalar zNear, kmScalar zFar);

/** Creates an orthographic projection matrix like glOrtho */
const kmMat4* kmMat4OrthographicProjection(kmMat4* pOut, kmScalar left, kmScalar right, kmScalar bottom, kmScalar top, kmScalar nearVal, kmScalar farVal);

/**
 * Builds a translation matrix in the same way as gluLookAt().
 * the resulting matrix is stored in pOut. pOut is returned.
 */
const kmMat4* kmMat4LookAt(kmMat4* pOut, const struct kmVec3* pEye, const struct kmVec3* pCenter, const struct kmVec3* pUp);

