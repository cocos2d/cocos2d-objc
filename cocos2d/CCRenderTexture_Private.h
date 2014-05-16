//
//  CCRenderTexture_Private.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 4/24/14.
//
//

#import "CCRenderTexture.h"

@interface CCRenderTexture() {

@protected
    GLenum _pixelFormat;
    GLuint _depthStencilFormat;

    CCRenderer *_renderer;
    BOOL _privateRenderer;

    GLKVector4 _clearColor;

    GLKVector4 _oldViewport;
    GLint _oldFBO;
    NSDictionary *_oldGlobalUniforms;


    float _contentScale;
    GLKMatrix4 _projection;
    CCTexture* _texture;

    CCSprite* _sprite;
    
    int _currentRenderPass;
    NSMutableArray *_textures;
    NSMutableArray *_FBOs;
    
    BOOL _contentSizeChanged;
}

-(void)destroy;

-(GLuint)fbo;

-(void)assignSpriteTexture;

@end
