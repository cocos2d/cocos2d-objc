//
//  CCTexture_Private.h
//  cocos2d-osx
//
//  Created by Viktor on 10/29/13.
//
//

#import "CCTexture.h"

@interface CCTexture ()

/** These functions are needed to create mutable textures */
- (void) releaseData:(void*)data;
- (void*) keepData:(void*)data length:(NSUInteger)length;

/** texture name */
@property(nonatomic,readonly) GLuint name;

/** texture max S */
@property(nonatomic,readwrite) GLfloat maxS;
/** texture max T */
@property(nonatomic,readwrite) GLfloat maxT;

@end

/**
 Drawing extensions to make it easy to draw basic quads using a CCTexture2D object.
 These functions require GL_TEXTURE_2D and both GL_VERTEX_ARRAY and GL_TEXTURE_COORD_ARRAY client states to be enabled.
 */
@interface CCTexture (Drawing)
/** draws a texture at a given point */
- (void) drawAtPoint:(CGPoint)point;
/** draws a texture inside a rect */
- (void) drawInRect:(CGRect)rect;
@end

/**
 Extensions to make it easy to create a CCTexture2D object from a PVRTC file
 Note that the generated textures don't have their alpha premultiplied - use the blending mode (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA).
 */
@interface CCTexture (PVRSupport)
/** Initializes a texture from a PVR file.
 
 Supported PVR formats:
 - BGRA 8888
 - RGBA 8888
 - RGBA 4444
 - RGBA 5551
 - RBG 565
 - A 8
 - I 8
 - AI 8
 - PVRTC 2BPP
 - PVRTC 4BPP
 
 By default PVR images are treated as if they alpha channel is NOT premultiplied. You can override this behavior with this class method:
 - PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied;
 
 IMPORTANT: This method is only defined on iOS. It is not supported on the Mac version.
 
 */
-(id) initWithPVRFile: (NSString*) file;

/** treats (or not) PVR files as if they have alpha premultiplied.
 Since it is impossible to know at runtime if the PVR images have the alpha channel premultiplied, it is
 possible load them as if they have (or not) the alpha channel premultiplied.
 
 By default it is disabled.
 
 @since v0.99.5
 */
+(void) PVRImagesHavePremultipliedAlpha:(BOOL)haveAlphaPremultiplied;

@end

/**
 Extension to set the Min / Mag filter
 */
typedef struct _ccTexParams {
	GLuint	minFilter;
	GLuint	magFilter;
	GLuint	wrapS;
	GLuint	wrapT;
} ccTexParams;

@interface CCTexture (GLFilter)
/** sets the min filter, mag filter, wrap s and wrap t texture parameters.
 If the texture size is NPOT (non power of 2), then in can only use GL_CLAMP_TO_EDGE in GL_TEXTURE_WRAP_{S,T}.
 
 @warning Calling this method could allocate additional texture memory.
 
 @since v0.8
 */
-(void) setTexParameters: (ccTexParams*) texParams;

/** sets antialias texture parameters:
 - GL_TEXTURE_MIN_FILTER = GL_LINEAR
 - GL_TEXTURE_MAG_FILTER = GL_LINEAR
 
 @warning Calling this method could allocate additional texture memory.
 
 @since v0.8
 */
- (void) setAntiAliasTexParameters;

/** sets alias texture parameters:
 - GL_TEXTURE_MIN_FILTER = GL_NEAREST
 - GL_TEXTURE_MAG_FILTER = GL_NEAREST
 
 @warning Calling this method could allocate additional texture memory.
 
 @since v0.8
 */
- (void) setAliasTexParameters;


/** Generates mipmap images for the texture.
 It only works if the texture size is POT (power of 2).
 @since v0.99.0
 */
-(void) generateMipmap;

@end
