//
//  CCMath.m
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 30.1.14.
//
//

#import "CCMath.h"


static GLKMatrixStackRef modelViewMatrixStack = NULL;
static GLKMatrixStackRef projectionMatrixStack = NULL;
static GLKMatrixStackRef textureMatrixStack = NULL;

static GLKMatrixStackRef currentStack = NULL;

static inline GLKMatrixStackRef stack()
{
    if (!currentStack) {
    
        
        modelViewMatrixStack = GLKMatrixStackCreate(NULL);
        projectionMatrixStack = GLKMatrixStackCreate(NULL);
        textureMatrixStack = GLKMatrixStackCreate(NULL);
        
        GLKMatrixStackLoadMatrix4(modelViewMatrixStack, GLKMatrix4Identity);
        GLKMatrixStackLoadMatrix4(projectionMatrixStack, GLKMatrix4Identity);
        GLKMatrixStackLoadMatrix4(textureMatrixStack, GLKMatrix4Identity);
        
        currentStack = modelViewMatrixStack;
    };
    return currentStack;
}



void CCGLFreeAll(void)
{
    if (modelViewMatrixStack) {
        CFRelease(modelViewMatrixStack);
        modelViewMatrixStack = NULL;
    }
    
    if (projectionMatrixStack) {
        CFRelease(projectionMatrixStack);
        projectionMatrixStack = NULL;
    }
    
    if (textureMatrixStack) {
        CFRelease(textureMatrixStack);
        textureMatrixStack = NULL;
    }
    
    currentStack = NULL;
    
}

void CCGLPushMatrix(void)
{
    GLKMatrixStackPush(stack());
}

void CCGLPopMatrix(void)
{
    GLKMatrixStackPop(stack());
}


void CCGLMatrixMode(CCMatrixMode mode)
{
    stack();
    
    switch(mode)
    {
        case CCGLModelView:
            currentStack = modelViewMatrixStack;
            break;
        case CCGLProjection:
            currentStack = projectionMatrixStack;
            break;
        case CCGLTexture:
            currentStack = textureMatrixStack;
            break;
        default:
            assert(0 && "Invalid matrix mode specified"); //TODO: Proper error handling
            break;
    }
}

GLKMatrix4 CCGLGetMatrix(CCMatrixMode mode)
{
    stack();
    
    switch(mode)
    {
        case CCGLModelView:
            return GLKMatrixStackGetMatrix4(modelViewMatrixStack);
            break;
        case CCGLProjection:
            return GLKMatrixStackGetMatrix4(projectionMatrixStack);
            break;
        case CCGLTexture:
            return GLKMatrixStackGetMatrix4(textureMatrixStack);
            break;
        default:
            assert(1 && "Invalid matrix mode specified"); //TODO: Proper error handling
            break;
    }
}


void CCGLMultMatrix(GLKMatrix4 matrix)
{
    GLKMatrixStackMultiplyMatrix4(stack(), matrix);
}

void CCGLLoadIdentity(void)
{
    GLKMatrixStackLoadMatrix4(stack(), GLKMatrix4Identity);
}

