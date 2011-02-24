/*
 * kazmath.c
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
 * 
 * See header file kazmath.h for full API documentation.
 */

#import "kazmath.h"
#import <memory.h>
#import <math.h>

#pragma mark -
#pragma mark vec3

// Returns a kmVec3 structure constructed from the vector components.
kmVec3 kmVec3Make(kmScalar x, kmScalar y, kmScalar z)
{
	kmVec3 v;
	v.x = x;
	v.y = y;
	v.z = z;
	return v;
}

// Returns the length of the vector.
kmScalar kmVec3Length(const kmVec3* pIn)
{
	return sqrtf((pIn->x * pIn->x) + (pIn->y * pIn->y) + (pIn->z * pIn->z));
}

// Normalizes the vector to unit length, stores the result in pOut and returns the result.
kmVec3* kmVec3Normalize(kmVec3* pOut, const kmVec3* pIn)
{
	kmScalar l = 1.0f / kmVec3Length(pIn);
	
	kmVec3 v;
	v.x = pIn->x * l;
	v.y = pIn->y * l;
	v.z = pIn->z * l;
	
	pOut->x = v.x;
	pOut->y = v.y;
	pOut->z = v.z;
	
	return pOut;
}

/**
 * Assigns pIn to pOut. Returns pOut. If pIn and pOut are the same
 * then nothing happens but pOut is still returned
 */
kmVec3* kmVec3Assign(kmVec3* pOut, const kmVec3* pIn)
{
	if (pOut == pIn) {
		return pOut;
	}
	
	pOut->x = pIn->x;
	pOut->y = pIn->y;
	pOut->z = pIn->z;
	
	return pOut;
}

/**
 * Returns a vector perpendicular to 2 other vectors.
 * The result is stored in pOut.
 */
kmVec3* kmVec3Cross(kmVec3* pOut, const kmVec3* pV1, const kmVec3* pV2)
{
	
	kmVec3 v;
	
	v.x = (pV1->y * pV2->z) - (pV1->z * pV2->y);
	v.y = (pV1->z * pV2->x) - (pV1->x * pV2->z);
	v.z = (pV1->x * pV2->y) - (pV1->y * pV2->x);
	
	pOut->x = v.x;
	pOut->y = v.y;
	pOut->z = v.z;
	
	return pOut;
}

/**
 * Subtracts 2 vectors and returns the result. The result is stored in
 * pOut.
 */
kmVec3* kmVec3Subtract(kmVec3* pOut, const kmVec3* pV1, const kmVec3* pV2)
{
	kmVec3 v;
	
	v.x = pV1->x - pV2->x;
	v.y = pV1->y - pV2->y;
	v.z = pV1->z - pV2->z;
	
	pOut->x = v.x;
	pOut->y = v.y;
	pOut->z = v.z;
	
	return pOut;
}

#pragma mark -
#pragma mark vec4

// Returns a kmVec4 structure constructed from the vector components.
kmVec4 kmVec4Make(kmScalar x, kmScalar y, kmScalar z, kmScalar w) {
	kmVec4 v;
	v.x = x;
	v.y = y;
	v.z = z;
	v.w = w;
	return v;
}

// Transforms a 4D vector by a matrix, the result is stored in pOut, and pOut is returned.
kmVec4* kmVec4Transform(kmVec4* pOut, const kmVec4* pV, const kmMat4* pM) {
	const kmScalar* m = pM->mat;

	pOut->x = pV->x * m[0] + pV->y * m[4] + pV->z * m[8] + pV->w * m[12];
	pOut->y = pV->x * m[1] + pV->y * m[5] + pV->z * m[9] + pV->w * m[13];
	pOut->z = pV->x * m[2] + pV->y * m[6] + pV->z * m[10] + pV->w * m[14];
    pOut->w = pV->x * m[3] + pV->y * m[7] + pV->z * m[11] + pV->w * m[15];

	return pOut;
}

#pragma mark -
#pragma mark Mat4

kmMat4* const kmMat4Identity(kmMat4* pOut)
{
	memset(pOut->mat, 0, sizeof(float) * 16);
	pOut->mat[0] = pOut->mat[5] = pOut->mat[10] = pOut->mat[15] = 1.0f;
	return pOut;
}

// Multiplies pM1 with pM2, stores the result in pOut, returns pOut
kmMat4* kmMat4Multiply(kmMat4* pOut, const kmMat4* pM1, const kmMat4* pM2) {
	float mat[16];
	const float *m1 = pM1->mat, *m2 = pM2->mat;
	
	mat[0] = m1[0] * m2[0] + m1[4] * m2[1] + m1[8] * m2[2] + m1[12] * m2[3];
	mat[1] = m1[1] * m2[0] + m1[5] * m2[1] + m1[9] * m2[2] + m1[13] * m2[3];
	mat[2] = m1[2] * m2[0] + m1[6] * m2[1] + m1[10] * m2[2] + m1[14] * m2[3];
	mat[3] = m1[3] * m2[0] + m1[7] * m2[1] + m1[11] * m2[2] + m1[15] * m2[3];
	
	mat[4] = m1[0] * m2[4] + m1[4] * m2[5] + m1[8] * m2[6] + m1[12] * m2[7];
	mat[5] = m1[1] * m2[4] + m1[5] * m2[5] + m1[9] * m2[6] + m1[13] * m2[7];
	mat[6] = m1[2] * m2[4] + m1[6] * m2[5] + m1[10] * m2[6] + m1[14] * m2[7];
	mat[7] = m1[3] * m2[4] + m1[7] * m2[5] + m1[11] * m2[6] + m1[15] * m2[7];
	
	mat[8] = m1[0] * m2[8] + m1[4] * m2[9] + m1[8] * m2[10] + m1[12] * m2[11];
	mat[9] = m1[1] * m2[8] + m1[5] * m2[9] + m1[9] * m2[10] + m1[13] * m2[11];
	mat[10] = m1[2] * m2[8] + m1[6] * m2[9] + m1[10] * m2[10] + m1[14] * m2[11];
	mat[11] = m1[3] * m2[8] + m1[7] * m2[9] + m1[11] * m2[10] + m1[15] * m2[11];
	
	mat[12] = m1[0] * m2[12] + m1[4] * m2[13] + m1[8] * m2[14] + m1[12] * m2[15];
	mat[13] = m1[1] * m2[12] + m1[5] * m2[13] + m1[9] * m2[14] + m1[13] * m2[15];
	mat[14] = m1[2] * m2[12] + m1[6] * m2[13] + m1[10] * m2[14] + m1[14] * m2[15];
	mat[15] = m1[3] * m2[12] + m1[7] * m2[13] + m1[11] * m2[14] + m1[15] * m2[15];
	
	memcpy(pOut->mat, mat, sizeof(float)*16);
	
	return pOut;
}

// Builds a translation matrix. All other elements in the matrix
// will be set to zero except for the diagonal which is set to 1.0
kmMat4* kmMat4Translation(kmMat4* pOut, const kmScalar x, const kmScalar y, const kmScalar z) {
/*
     | 1  0  0  x |
 M = | 0  1  0  y |
     | 0  0  1  z |
     | 0  0  0  1 |
*/
	kmScalar* m = pOut->mat;
	
    memset(m, 0, sizeof(float) * 16);
	
    m[0] = 1.0f;
    m[5] = 1.0f;
    m[10] = 1.0f;
	
    m[12] = x;
    m[13] = y;
    m[14] = z;
    m[15] = 1.0f;
	
    return pOut;
}

// Builds a rotation matrix that rotates around all three axes, y (yaw), x (pitch), z (roll),
// (equivalently to separate rotations, in that order), stores the result in pOut and returns the result.
kmMat4* kmMat4RotationYXZ(kmMat4* pOut, const kmScalar xRadians, const kmScalar yRadians, const kmScalar zRadians) {
/*
     |  cycz + sxsysz   czsxsy - cysz   cxsy  0 |
 M = |  cxsz            cxcz           -sx    0 |
     |  cysxsz - czsy   cyczsx + sysz   cxcy  0 |
     |  0               0               0     1 |
	 
     where cA = cos(A), sA = sin(A) for A = x,y,z
 */
	kmScalar* m = pOut->mat;
	
	kmScalar cx = cosf(xRadians);
	kmScalar sx = sinf(xRadians);
	kmScalar cy = cosf(yRadians);
	kmScalar sy = sinf(yRadians);
	kmScalar cz = cosf(zRadians);
	kmScalar sz = sinf(zRadians);
	
	m[0] = (cy * cz) + (sx * sy * sz);
	m[1] = cx * sz;
	m[2] = (cy * sx * sz) - (cz * sy);
	m[3] = 0.0;
	
	m[4] = (cz * sx * sy) - (cy * sz);
	m[5] = cx * cz;
	m[6] = (cy * cz * sx) + (sy * sz);
	m[7] = 0.0;
	
	m[8] = cx * sy;
	m[9] = -sx;
	m[10] = cx * cy;
	m[11] = 0.0;
	
	m[12] = 0.0;
	m[13] = 0.0;
	m[14] = 0.0;
	m[15] = 1.0;
	
	return pOut;
}

// Builds a rotation matrix that rotates around all three axes, z (roll), y (yaw), x (pitch),
// (equivalently to separate rotations, in that order), stores the result in pOut and returns the result.
kmMat4* kmMat4RotationZYX(kmMat4* pOut, const kmScalar xRadians, const kmScalar yRadians, const kmScalar zRadians) {
/*
     |  cycz  -cxsz + sxsycz   sxsz + cxsycz  0 |
 M = |  cysz   cxcz + sxsysz  -sxcz + cxsysz  0 |
     | -sy     sxcy            cxcy           0 |
     |  0      0               0              1 |

     where cA = cos(A), sA = sin(A) for A = x,y,z
*/
	kmScalar* m = pOut->mat;

	kmScalar cx = cosf(xRadians);
	kmScalar sx = sinf(xRadians);
	kmScalar cy = cosf(yRadians);
	kmScalar sy = sinf(yRadians);
	kmScalar cz = cosf(zRadians);
	kmScalar sz = sinf(zRadians);
	
	m[0] = cy * cz;
	m[1] = cy * sz;
	m[2] = -sy;
	m[3] = 0.0;
	
	m[4] = -(cx * sz) + (sx * sy * cz);
	m[5] = (cx * cz) + (sx * sy * sz);
	m[6] = sx * cy;
	m[7] = 0.0;
	
	m[8] = (sx * sz) + (cx * sy * cz);
	m[9] = -(sx * cz) + (cx * sy * sz);
	m[10] = cx * cy;
	m[11] = 0.0;
	
	m[12] = 0.0;
	m[13] = 0.0;
	m[14] = 0.0;
	m[15] = 1.0;
	
	return pOut;
}

// Builds a rotation matrix around the X-axis, stores the result in pOut and returns the result
kmMat4* kmMat4RotationX(kmMat4* pOut, const float radians) {
/*
     |  1  0       0       0 |
 M = |  0  cos(A) -sin(A)  0 |
     |  0  sin(A)  cos(A)  0 |
     |  0  0       0       1 |
*/
	kmScalar* m = pOut->mat;
	
	m[0] = 1.0f;
	m[1] = 0.0f;
	m[2] = 0.0f;
	m[3] = 0.0f;
	
	m[4] = 0.0f;
	m[5] = cosf(radians);
	m[6] = sinf(radians);
	m[7] = 0.0f;
	
	m[8] = 0.0f;
	m[9] = -sinf(radians);
	m[10] = cosf(radians);
	m[11] = 0.0f;
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
	
	return pOut;
}

// Builds a rotation matrix around the Y-axis, stores the result in pOut and returns the result
kmMat4* kmMat4RotationY(kmMat4* pOut, const float radians) {
/*
     |  cos(A)  0   sin(A)  0 |
 M = |  0       1   0       0 |
     | -sin(A)  0   cos(A)  0 |
     |  0       0   0       1 |
*/
	kmScalar* m = pOut->mat;
	
	m[0] = cosf(radians);
	m[1] = 0.0f;
	m[2] = -sinf(radians);
	m[3] = 0.0f;
	
	m[4] = 0.0f;
	m[5] = 1.0f;
	m[6] = 0.0f;
	m[7] = 0.0f;
	
	m[8] = sinf(radians);
	m[9] = 0.0f;
	m[10] = cosf(radians);
	m[11] = 0.0f;
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
	
	return pOut;
}

// Builds a rotation matrix around the Z-axis, stores the result in pOut and returns the result
kmMat4* kmMat4RotationZ(kmMat4* pOut, const float radians) {
/*
     |  cos(A)  -sin(A)   0   0 |
 M = |  sin(A)   cos(A)   0   0 |
     |  0        0        1   0 |
     |  0        0        0   1 |
*/
	kmScalar* m = pOut->mat;
	
	m[0] = cosf(radians);
	m[1] = sinf(radians);
	m[2] = 0.0f;
	m[3] = 0.0f;
	
	m[4] = -sinf(radians);;
	m[5] = cosf(radians);
	m[6] = 0.0f;
	m[7] = 0.0f;
	
	m[8] = 0.0f;
	m[9] = 0.0f;
	m[10] = 1.0f;
	m[11] = 0.0f;
	
	m[12] = 0.0f;
	m[13] = 0.0f;
	m[14] = 0.0f;
	m[15] = 1.0f;
	
	return pOut;
}

// Build a rotation matrix from an axis and an angle, stores the result in pOut and returns the result.
kmMat4* kmMat4RotationAxisAngle(kmMat4* pOut, const kmVec3* axis, kmScalar radians) {
/*
     |      									|
     | C + XX(1 - C)   -ZS + XY(1-C)  YS + ZX(1-C)   0 |
     |                                                 |
M =  | ZS + XY(1-C)    C + YY(1 - C)  -XS + YZ(1-C)  0 |
     |                                                 |
     | -YS + ZX(1-C)   XS + YZ(1-C)   C + ZZ(1 - C)  0 |
     |                                                 |
     |      0              0               0         1 |

     where X, Y, Z define axis of rotation and C = cos(A), S = sin(A) for A = angle of rotation
*/
	kmScalar ca = cosf(radians);
	kmScalar sa = sinf(radians);
	
	kmVec3 rax;
	kmVec3Normalize(&rax, axis);
	
	pOut->mat[0] = ca + rax.x * rax.x * (1 - ca);
	pOut->mat[1] = rax.z * sa + rax.y * rax.x * (1 - ca);
	pOut->mat[2] = -rax.y * sa + rax.z * rax.x * (1 - ca);
	pOut->mat[3] = 0.0f;
	
	pOut->mat[4] = -rax.z * sa + rax.x * rax.y * (1 - ca);
	pOut->mat[5] = ca + rax.y * rax.y * (1 - ca);
	pOut->mat[6] = rax.x * sa + rax.z * rax.y * (1 - ca);
	pOut->mat[7] = 0.0f;
	
	pOut->mat[8] = rax.y * sa + rax.x * rax.z * (1 - ca);
	pOut->mat[9] = -rax.x * sa + rax.y * rax.z * (1 - ca);
	pOut->mat[10] = ca + rax.z * rax.z * (1 - ca);
	pOut->mat[11] = 0.0f;
	
	pOut->mat[12] = 0.0f;
	pOut->mat[13] = 0.0f;
	pOut->mat[14] = 0.0f;
	pOut->mat[15] = 1.0f;
	
	return pOut;
}

// Builds a scaling matrix, stores the result in pOut and returns the result
kmMat4* kmMat4Scaling(kmMat4* pOut, const kmScalar x, const kmScalar y, const kmScalar z) {
/*
     |  x  0  0  0 |
 M = |  0  y  0  0 |
     |  0  0  z  0 |
     |  0  0  0  1 |
*/
	kmScalar* m = pOut->mat;
	
	memset(m, 0, sizeof(float) * 16);
	m[0] = x;
	m[5] = y;
	m[10] = z;
	m[15] = 1.0f;
	
	return pOut;
}

// Builds a transformation matrix that translates, rotates and scales according to the specified vectors,
// stores the result in pOut and returns the result
kmMat4* kmMat4Transformation(kmMat4* pOut, const kmVec3 translation, const kmVec3 rotation, const kmVec3 scale) {
/*
     |  gxR0  gyR4  gzR8   tx |
 M = |  gxR1  gyR5  gzR9   ty |
     |  gxR2  gyR6  gzR10  tz |
     |  0     0     0      1  |
	 
     where Rn is an element of the rotation matrix (R0 - R15).
     where tx = translation.x, ty = translation.y, tz = translation.z
     where gx = scale.x, gy = scale.y, gz = scale.z
*/	

	// Start with basic rotation matrix
	kmMat4RotationYXZ(pOut, rotation.x, rotation.y, rotation.z);
	
	// Adjust for scale and translation
	kmScalar* m = pOut->mat;

	m[0] *= scale.x;
	m[1] *= scale.x;
	m[2] *= scale.x;
	m[3] = 0.0;
	
	m[4] *= scale.y;
	m[5] *= scale.y;
	m[6] *= scale.y;
	m[7] = 0.0;
	
	m[8] *= scale.z;
	m[9] *= scale.z;
	m[10] *= scale.z;
	m[11] = 0.0;
	
	m[12] = translation.x;
	m[13] = translation.y;
	m[14] = translation.z;
	m[15] = 1.0;
	
	return pOut;
}

float kmMatGet(const kmMat4* pIn, int row, int col) {
	return pIn->mat[row + 4*col];
}

void kmMatSet(kmMat4* pIn, int row, int col, float value) {
	pIn->mat[row + 4*col] = value;
}

void kmMatSwap(kmMat4* pIn, int r1, int c1, int r2, int c2) {
	float tmp = kmMatGet(pIn,r1,c1);
	kmMatSet(pIn,r1,c1,kmMatGet(pIn,r2,c2));
	kmMatSet(pIn,r2,c2, tmp);
}

#pragma mark -
#pragma mark Projection

/**
 * Creates a perspective projection matrix in the
 * same way as gluPerspective
 */
kmMat4* const kmMat4PerspectiveProjection(kmMat4* pOut, kmScalar fovY,
										  kmScalar aspect, kmScalar zNear,
										  kmScalar zFar)
{
#ifndef CC_DEGREES_TO_RADIANS
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180
#endif

	kmScalar r = DEGREES_TO_RADIANS(fovY / 2);
	kmScalar deltaZ = zFar - zNear;
	kmScalar s = sin(r);
    kmScalar cotangent = 0;
	
	if (deltaZ == 0 || s == 0 || aspect == 0) {
		return NULL;
	}
	
    //cos(r) / sin(r) = cot(r)
	cotangent = cos(r) / s;
	
	kmMat4Identity(pOut);
	pOut->mat[0] = cotangent / aspect;
	pOut->mat[5] = cotangent;
	pOut->mat[10] = -(zFar + zNear) / deltaZ;
	pOut->mat[11] = -1;
	pOut->mat[14] = -2 * zNear * zFar / deltaZ;
	pOut->mat[15] = 0;
	
	return pOut;
}

/** Creates an orthographic projection matrix like glOrtho */
kmMat4* const kmMat4OrthographicProjection(kmMat4* pOut, kmScalar left,
										   kmScalar right, kmScalar bottom,
										   kmScalar top, kmScalar nearVal,
										   kmScalar farVal)
{
	kmScalar tx = -((right + left) / (right - left));
	kmScalar ty = -((top + bottom) / (top - bottom));
	kmScalar tz = -((farVal + nearVal) / (farVal - nearVal));
	
	kmMat4Identity(pOut);
	pOut->mat[0] = 2 / (right - left);
	pOut->mat[5] = 2 / (top - bottom);
	pOut->mat[10] = -2 / (farVal - nearVal);
	pOut->mat[12] = tx;
	pOut->mat[13] = ty;
	pOut->mat[14] = tz;
	
	return pOut;
}

/**
 * Builds a translation matrix in the same way as gluLookAt()
 * the resulting matrix is stored in pOut. pOut is returned.
 */
kmMat4* const kmMat4LookAt(kmMat4* pOut, const kmVec3* pEye,
						   const kmVec3* pCenter, const kmVec3* pUp)
{
    kmVec3 f, up, s, u;
    kmMat4 translate;
	
    kmVec3Subtract(&f, pCenter, pEye);
    kmVec3Normalize(&f, &f);
	
    kmVec3Assign(&up, pUp);
    kmVec3Normalize(&up, &up);
	
    kmVec3Cross(&s, &f, &up);
    kmVec3Normalize(&s, &s);
	
    kmVec3Cross(&u, &s, &f);
    kmVec3Normalize(&s, &s);
	
    kmMat4Identity(pOut);
	
    pOut->mat[0] = s.x;
    pOut->mat[4] = s.y;
    pOut->mat[8] = s.z;
	
    pOut->mat[1] = u.x;
    pOut->mat[5] = u.y;
    pOut->mat[9] = u.z;
	
    pOut->mat[2] = -f.x;
    pOut->mat[6] = -f.y;
    pOut->mat[10] = -f.z;
	
    kmMat4Translation(&translate, -pEye->x, -pEye->y, -pEye->z);
    kmMat4Multiply(pOut, pOut, &translate);
	
    return pOut;
}
