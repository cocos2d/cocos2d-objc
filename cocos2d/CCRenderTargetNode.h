//
//  Created by krzysztof.zablocki on 8/19/12.
//
//
//


#import <Foundation/Foundation.h>
#import "ccMacros.h"
#import "CCNode.h"
#import "CCSprite.h"
#import "Support/OpenGL_Internal.h"
#import "kazmath/mat4.h"
@class CCRenderTexture;

#define CC_GL_CLEAR_COLOR GL_COLOR_BUFFER_BIT
#define CC_GL_CLEAR_DEPTH GL_DEPTH_BUFFER_BIT
#define CC_GL_CLEAR_STENCIL CC_GL_CLEAR_STENCIL

/*
 CCRenderTargetNode is a real rendering target node, it render all its children into CCRenderTexture.
 Each CCRenderTexture has lazy created CCRenderTargetNode, so you can add any nodes that you want to render inside render texture into renderTexture.renderTargetNode.
 You can also use it to render to texture that isn't in tree, you just need to make sure the render texture isn't released before this node, as it doesn't retain renderTexture.
 If you specify clearFlags for render target node it will clear render texture content each frame before before rendering.
 */
@interface CCRenderTargetNode : CCNode
//- (void)beginWithClear:(float)r g:(float)g b:(float)b a:(float)a depth:(float)depthValue stencil:(int)stencilValue;

@property (nonatomic, assign) GLbitfield clearFlags; // default to none, use CC_GL_CLEAR_X

//! values used for clearing when clearFlags are set to corresponding bits
@property (nonatomic, assign) ccColor4F clearColor;
@property (nonatomic, assign) GLfloat clearDepth;
@property (nonatomic, assign) GLint clearStencil;

//! doesn't retain render texture, it's your responsibility to make sure texture is not released before this node
- (id)initWithRenderTexture:(CCRenderTexture *)texture;

@end
