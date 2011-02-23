/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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


#import "TransformUtils.h"

void CGAffineToGL(const CGAffineTransform *t, GLfloat *m)
{
	// | m[0] m[4] m[8]  m[12] |     | m11 m21 m31 m41 |     | a c 0 tx |
	// | m[1] m[5] m[9]  m[13] |     | m12 m22 m32 m42 |     | b d 0 ty |
	// | m[2] m[6] m[10] m[14] | <=> | m13 m23 m33 m43 | <=> | 0 0 1  0 |
	// | m[3] m[7] m[11] m[15] |     | m14 m24 m34 m44 |     | 0 0 0  1 |
	
	m[2] = m[3] = m[6] = m[7] = m[8] = m[9] = m[11] = m[14] = 0.0f;
	m[10] = m[15] = 1.0f;
	m[0] = t->a; m[4] = t->c; m[12] = t->tx;
	m[1] = t->b; m[5] = t->d; m[13] = t->ty;
}

void GLToCGAffine(const GLfloat *m, CGAffineTransform *t)
{
	t->a = m[0]; t->c = m[4]; t->tx = m[12];
	t->b = m[1]; t->d = m[5]; t->ty = m[13];
}

void ccMatrixFrustum(GLfloat *matrix, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far)
{
	GLfloat a = 2 * near / (right - left);
	GLfloat b = 2 * near / (top - bottom);
	GLfloat A = (right + left) / (right - left);
	GLfloat B = (top + bottom) / (top - bottom);
	GLfloat C = - (far + near) / (far - near);
	GLfloat D = -2 * far * near / (far - near);

	
#define M(row,col)  matrix[col*4+row]
    M(0, 0) = a;
    M(0, 1) = 0;
    M(0, 2) = A;
    M(0, 3) = 0;
	
    M(1, 0) = 0;
    M(1, 1) = b;
    M(1, 2) = B;
    M(1, 3) = 0;
	
    M(2, 0) = 0;
    M(2, 1) = 0;
    M(2, 2) = C;
    M(2, 3) = D;
	
    M(3, 0) = 0;
    M(3, 1) = 0;
    M(3, 2) = -1;
    M(3, 3) = 0;	// Should this be 0 or 1 ?
#undef M
}

void ccMatrixOrtho(GLfloat *matrix, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far)
{
	GLfloat a = 2 / (right - left);
	GLfloat b = 2 / (top - bottom);
	GLfloat c = -2 / (far - near );
	GLfloat tx = - (right + left) / (right - left);
	GLfloat ty = - (top + bottom) / (top - bottom);
	GLfloat tz = - (far + near) / (far - near);
	
	
#define M(row,col)  matrix[col*4+row]
    M(0, 0) = a;
    M(0, 1) = 0;
    M(0, 2) = 0;
    M(0, 3) = tx;
    M(1, 0) = 0;
    M(1, 1) = b;
    M(1, 2) = 0;
    M(1, 3) = ty;
    M(2, 0) = 0;
    M(2, 1) = 0;
    M(2, 2) = c;
    M(2, 3) = tz;
    M(3, 0) = 0;
    M(3, 1) = 0;
    M(3, 2) = 0;
    M(3, 3) = 1;
#undef M
}

void ccMatrixPerspective(GLfloat *matrix, GLfloat fovy, GLfloat aspect,GLfloat zNear,GLfloat zFar )
{
	GLfloat xmin, xmax, ymin, ymax;
	ymax = zNear * tan(fovy * M_PI / 360.0);
	ymin = -ymax;
	xmin = ymin * aspect;
	xmax = ymax * aspect;
	printf("l:%f r:%f, b:%f, t:%f, n:%f, f:%f\n", xmin, xmax, ymin, ymax, zNear, zFar);
	ccMatrixFrustum(matrix, xmin, xmax, ymin, ymax, zNear, zFar);
}

void ccMatrixLookAt(GLfloat *matrix,
				GLfloat eyex, GLfloat eyey, GLfloat eyez,
				GLfloat centerx, GLfloat centery, GLfloat centerz,
				GLfloat upx, GLfloat upy, GLfloat upz)
{
    GLfloat x[3], y[3], z[3];
    GLfloat mag;
	
    /* Make rotation matrix */
	
    /* Z vector */
    z[0] = eyex - centerx;
    z[1] = eyey - centery;
    z[2] = eyez - centerz;
    mag = (float)sqrtf(z[0] * z[0] + z[1] * z[1] + z[2] * z[2]);
    if (mag) {
        z[0] /= mag;
        z[1] /= mag;
        z[2] /= mag;
    }
	
    /* Y vector */
    y[0] = upx;
    y[1] = upy;
    y[2] = upz;
	
    /* X vector = Y cross Z */
    x[0] = y[1] * z[2] - y[2] * z[1];
    x[1] = -y[0] * z[2] + y[2] * z[0];
    x[2] = y[0] * z[1] - y[1] * z[0];
	
    /* Recompute Y = Z cross X */
    y[0] = z[1] * x[2] - z[2] * x[1];
    y[1] = -z[0] * x[2] + z[2] * x[0];
    y[2] = z[0] * x[1] - z[1] * x[0];
	
    /* cross product gives area of parallelogram, which is < 1.0 for
     * non-perpendicular unit-length vectors; so normalize x, y here
     */
	
    mag = (float)sqrtf(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
    if (mag) {
        x[0] /= mag;
        x[1] /= mag;
        x[2] /= mag;
    }
	
    mag = (float)sqrtf(y[0] * y[0] + y[1] * y[1] + y[2] * y[2]);
    if (mag) {
        y[0] /= mag;
        y[1] /= mag;
        y[2] /= mag;
    }
	
#define M(row,col)  matrix[col*4+row]
    M(0, 0) = x[0];
    M(0, 1) = x[1];
    M(0, 2) = x[2];
    M(0, 3) = 0.0f;
    M(1, 0) = y[0];
    M(1, 1) = y[1];
    M(1, 2) = y[2];
    M(1, 3) = 0.0f;
    M(2, 0) = z[0];
    M(2, 1) = z[1];
    M(2, 2) = z[2];
    M(2, 3) = 0.0f;
    M(3, 0) = 0.0f;
    M(3, 1) = 0.0f;
    M(3, 2) = 0.0f;
    M(3, 3) = 1.0f;

	
    /* Translate Eye to Origin */
//    glTranslatef(-eyex, -eyey, -eyez);

	M(0,3) = M(0,3) - eyex;
	M(1,3) = M(1,3) - eyey;
	M(2,3) = M(2,3) - eyez;
#undef M
}

void ccMatrixMult4(GLfloat *matrix, GLfloat *matrixA, GLfloat *matrixB)
{
	for( int i=0; i<4; i++) {
#define M(row,col)  matrix[row*4+col]
#define A(row,col)  matrixA[row*4+col]
#define B(row,col)  matrixB[row*4+col]
		M(i,0) = (A(i,0) * B(0,0)) + (A(i,1) * B(1,0)) + (A(i,2) * B(2,0)) + (A(i,3) * B(3,0));
		M(i,1) = (A(i,0) * B(0,1)) + (A(i,1) * B(1,1)) + (A(i,2) * B(2,1)) + (A(i,3) * B(3,1));
		M(i,2) = (A(i,0) * B(0,2)) + (A(i,1) * B(1,2)) + (A(i,2) * B(2,2)) + (A(i,3) * B(3,2));
		M(i,3) = (A(i,0) * B(0,3)) + (A(i,1) * B(1,3)) + (A(i,2) * B(2,3)) + (A(i,3) * B(3,3));
#undef M
#undef A
#undef B
	}
}

