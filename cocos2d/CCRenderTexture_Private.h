//
//  CCRenderTexture_Private.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/24/14.
//
//

#import "CCRenderTexture.h"

@class CCFrameBufferObject;

@interface CCRenderTexture() {

@protected
    GLenum _pixelFormat;
    GLuint _depthStencilFormat;
		
		// Reference to the previous render to be restored by end.
		CCRenderer *_previousRenderer;

    GLKVector4 _clearColor;

    float _contentScale;
    GLKMatrix4 _projection;

    CCSprite* _sprite;
    
    CCFrameBufferObject *_framebuffer;
    
    BOOL _contentSizeChanged;
}

-(void)createTextureAndFboWithPixelSize:(CGSize)pixelSize;
-(void)destroy;

-(void)assignSpriteTexture;

@end
