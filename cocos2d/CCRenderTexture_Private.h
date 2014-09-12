//
//  CCRenderTexture_Private.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/24/14.
//
//

#import "CCRenderTexture.h"

@class CCRenderTextureFBO;

@interface CCRenderTexture() {

@protected
    GLenum _pixelFormat;
    GLuint _depthStencilFormat;
		
		#warning TODO remove me.
    CCRenderer *_renderer;
		// Reference to the previous render to be restored by end.
		CCRenderer *_previousRenderer;

    GLKVector4 _clearColor;

    GLKVector4 _oldViewport;
    GLint _oldFBO;
    NSDictionary *_oldGlobalUniforms;


    float _contentScale;
    GLKMatrix4 _projection;

    CCSprite* _sprite;
    
    CCRenderTextureFBO *_FBO;
    
    BOOL _contentSizeChanged;
}

-(void)createTextureAndFboWithPixelSize:(CGSize)pixelSize;
-(void)destroy;

-(GLuint)fbo;

-(void)assignSpriteTexture;

@end
