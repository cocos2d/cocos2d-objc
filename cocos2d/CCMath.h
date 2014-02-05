//
//  CCMath.h
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 30.1.14.
//
//

#import <GLKit/GLKit.h>

typedef enum {
    CCGLModelView,
    CCGLProjection,
    CCGLTexture
} CCMatrixMode;

void CCGLPushMatrix(void);
void CCGLPopMatrix(void);

void CCGLMatrixMode(CCMatrixMode mode);

void CCGLMultMatrix(GLKMatrix4 matrix);
void CCGLLoadIdentity(void);

GLKMatrix4 CCGLGetMatrix(CCMatrixMode mode);

void CCGLFreeAll(void);
