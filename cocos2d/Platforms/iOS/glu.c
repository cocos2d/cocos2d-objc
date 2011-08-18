//
// cocos2d (incomplete) GLU implementation
//
// gluLookAt and gluPerspective from:
// http://jet.ro/creations (San Angeles Observation)
// 
// 

// Only compile this code on iOS. These files should NOT be included on your Mac project.
// But in case they are included, it won't be compiled.
#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

#import <OpenGLES/ES1/gl.h>
#import <math.h>
#import "../../Support/OpenGL_Internal.h"
#include "glu.h"

//void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
//{	
//	GLfloat xmin, xmax, ymin, ymax;
//		
//	ymax = zNear * (GLfloat)tanf(fovy * (float)M_PI / 360);
//	ymin = -ymax;
//	xmin = ymin * aspect;
//	xmax = ymax * aspect;
//		
//	glFrustumf(xmin, xmax,
//				ymin, ymax,
//				zNear, zFar);	
//}
//
//void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
//					  GLfloat centerx, GLfloat centery, GLfloat centerz,
//					  GLfloat upx, GLfloat upy, GLfloat upz)
//{
//    GLfloat m[16];
//    GLfloat x[3], y[3], z[3];
//    GLfloat mag;
//	
//    /* Make rotation matrix */
//	
//    /* Z vector */
//    z[0] = eyex - centerx;
//    z[1] = eyey - centery;
//    z[2] = eyez - centerz;
//    mag = (float)sqrtf(z[0] * z[0] + z[1] * z[1] + z[2] * z[2]);
//    if (mag) {
//        z[0] /= mag;
//        z[1] /= mag;
//        z[2] /= mag;
//    }
//	
//    /* Y vector */
//    y[0] = upx;
//    y[1] = upy;
//    y[2] = upz;
//	
//    /* X vector = Y cross Z */
//    x[0] = y[1] * z[2] - y[2] * z[1];
//    x[1] = -y[0] * z[2] + y[2] * z[0];
//    x[2] = y[0] * z[1] - y[1] * z[0];
//	
//    /* Recompute Y = Z cross X */
//    y[0] = z[1] * x[2] - z[2] * x[1];
//    y[1] = -z[0] * x[2] + z[2] * x[0];
//    y[2] = z[0] * x[1] - z[1] * x[0];
//	
//    /* cross product gives area of parallelogram, which is < 1.0 for
//     * non-perpendicular unit-length vectors; so normalize x, y here
//     */
//	
//    mag = (float)sqrtf(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
//    if (mag) {
//        x[0] /= mag;
//        x[1] /= mag;
//        x[2] /= mag;
//    }
//	
//    mag = (float)sqrtf(y[0] * y[0] + y[1] * y[1] + y[2] * y[2]);
//    if (mag) {
//        y[0] /= mag;
//        y[1] /= mag;
//        y[2] /= mag;
//    }
//	
//#define M(row,col)  m[col*4+row]
//    M(0, 0) = x[0];
//    M(0, 1) = x[1];
//    M(0, 2) = x[2];
//    M(0, 3) = 0.0f;
//    M(1, 0) = y[0];
//    M(1, 1) = y[1];
//    M(1, 2) = y[2];
//    M(1, 3) = 0.0f;
//    M(2, 0) = z[0];
//    M(2, 1) = z[1];
//    M(2, 2) = z[2];
//    M(2, 3) = 0.0f;
//    M(3, 0) = 0.0f;
//    M(3, 1) = 0.0f;
//    M(3, 2) = 0.0f;
//    M(3, 3) = 1.0f;
//#undef M
//	
//	glMultMatrixf(m);
//
//	
//    /* Translate Eye to Origin */
//    glTranslatef(-eyex, -eyey, -eyez);
//}

// Optimizations from http://www.cocos2d-iphone.org/forum/topic/10433
void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez, GLfloat centerx, GLfloat centery, GLfloat centerz, GLfloat upx, GLfloat upy, GLfloat upz) {
    GLfloat m[16];
    float fmult, magf;
    GLfloat z1, z2, z3, y1, y2, y3, x1, x2, x3;
    
    z1 = eyex - centerx;
    z2 = eyey - centery;
    z3 = eyez - centerz;
    magf = sqrtf( z1 * z1 + z2 * z2 + z3 * z3);
    if ( magf != 0 ) {
        fmult = ( 1.0f / magf);
    } else {
        fmult = 0;
    }
    z1 *= fmult;
    z2 *= fmult;
    z3 *= fmult;
    
    x1 = upy * z3 - upz * z2;
    x2 = -upx * z3 + upz * z1;
    x3 = upx * z2 - upy * z1;
    y1 = z2 * x3 - z3 * x2;
    y2 = -z1 * x3 + z3 * x1;
    y3 = z1 * x2 - z2 * x1;
    
    magf = sqrtf(  x1 * x1 + x2 * x2 + x3 * x3);
    if ( magf != 0 ) {
        fmult = (1.0f / magf);
    } else {
        fmult = 0;
    }
    
    x1 *= fmult;
    x2 *= fmult;
    x3 *= fmult;
    
    magf = sqrtf( y1 * y1 + y2 * y2 + y3 * y3 );
    if ( magf != 0 ) {
        fmult = ( 1.0f / magf);
    } else {
        fmult = 0;
    }
    y1 *= fmult;
    y2 *= fmult;
    y3 *= fmult;
    
    m[0] = x1;
    m[4] = x2;
    m[8] = x3;
    
    m[1] = y1;
    m[5] = y2;
    m[9] = y3;
    
    m[2] = z1;
    m[6] = z2;
    m[10] = z3;
    m[12] = m[13] = m[14] = m[3] = m[7] = m[11] = 0.0f;
    m[15] = 1.0f;
    
    glMultMatrixf( m );
    glTranslatef(-eyex, -eyey, -eyez);
}

void aglFrustumf(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat nearval, GLfloat farval) {
    GLfloat m[16];
    
    float nearValT = (2.0f * nearval);
    float fm_nearMult = 1.0f / (farval - nearval);
    float tm_btmMult = 1.0f / (top - bottom);
    float rm_leftMult = 1.0f / (right - left);
    
    m[0] = nearValT * rm_leftMult;
    m[5] = nearValT * tm_btmMult;
    m[2] = (right + left) * rm_leftMult;
    m[6] = (top + bottom) * tm_btmMult;
    m[10] = -(farval + nearval) * fm_nearMult;
    m[11] = -(farval * nearValT) * fm_nearMult;
    m[3] = m[7] = m[15] = 0.0f;
    m[4] = m[8] = m[12] = 0.0f;
    m[1] = m[9] = m[13] = 0.0f;
    m[14] = -1.0f;
    
    glMultMatrixf(m);
}

void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar) {
	GLfloat xmin, xmax, ymin, ymax;
    
	ymax = zNear * (GLfloat)tanf(fovy * 0.008726646f);    // (float)M_PI / 360);
	ymin = -ymax;
	xmin = ymin * aspect;
	xmax = ymax * aspect;
    
	aglFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
}

#endif // __IPHONE_OS_VERSION_MAX_ALLOWED
